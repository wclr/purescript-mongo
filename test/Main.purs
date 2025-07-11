module Test.Main where

import Prelude

import Control.Alt ((<|>))
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Array as Array
import Data.Bifunctor (lmap)
import Data.Codec (codec', decode, encode)
import Data.Codec.Argonaut (JsonCodec, prismaticCodec)
import Data.Codec.Argonaut (JsonDecodeError(..))
import Data.Codec.Argonaut.Common as C
import Data.Codec.Argonaut.Record (object)
import Data.DateTime (DateTime)
import Data.DateTime.Instant as Instant
import Data.Either (Either(..), either, hush, isLeft, isRight)
import Data.Int as Int
import Data.Maybe (Maybe(..), fromMaybe', isJust, isNothing, maybe)
import Data.Newtype (unwrap)
import Data.Nullable (Nullable, toMaybe)
import Data.Number as Number
import Data.Number.Format as NF
import Data.String (toLower)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple.Nested ((/\))
import Debug (spy)
import Effect (Effect)
import Effect.Aff (Aff, apathize, attempt, catchError, error, launchAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Now as Now
import Foreign.Object as Object
import MongoDb (ObjectId, dropDatabase)
import MongoDb as Mongo
import MongoDb.EJSON as EJSON
import MongoDb.ObjectId as ObjectId
import MongoDb.ObjectId.HexString as HexString
import MongoDb.Query (Query)
import MongoDb.Query as Q
import Partial.Unsafe (unsafeCrashWith)
import Test.Spec (class Example, class FocusWarning, SpecT, before, describe, describeOnly, it, itOnly, pending)
import Test.Spec.Assertions (fail, shouldEqual, shouldSatisfy)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Unsafe.Coerce (unsafeCoerce)

type Inner = { number :: Number, text :: String }

type Item = { id :: Int, name :: String, inner :: Inner }

searchQuery :: Query Item
searchQuery = Q.or
  [ Q.by { id: Q.eq 26637 }
  --, Q.by { da: Int 1 }
  , Q.by { inner: { text: Q.lte "10.0" } }
  ]

type TestParams =
  { client :: Mongo.Client
  , db :: Mongo.Db
  , col :: Mongo.Collection
  , colName :: String
  }

isNull :: forall a. Nullable a -> Boolean
isNull = isNothing <<< toMaybe

fit ::
  forall m t arg g.
  FocusWarning =>
  Monad m =>
  Example t arg g =>
  String ->
  t ->
  SpecT g arg m Unit
fit = itOnly

xit :: forall t17 m18 g19 i20. Monad m18 => String -> t17 -> SpecT g19 i20 m18 Unit
xit name _ = pending name

makeDoc :: forall a. EncodeJson a => a -> Mongo.Document
makeDoc obj = unsafeCoerce (encodeJson obj)

filterBy :: ∀ r. Record r -> Mongo.Filter
filterBy rec = unsafeCoerce rec

tests :: forall m. Monad m => SpecT Aff TestParams m Unit
tests = do
  it "creates unique index with createIndex" $ \{ col } -> do
    let indexKey = Object.fromFoldable [ "x" /\ 1 ]
    result <- Mongo.createIndexes col
      [ { name: "my-index", unique: true, key: indexKey } ]

    result `shouldEqual` [ "my-index" ]

    let doc = makeDoc { x: 1 }
    _ <- Mongo.insertOne col doc
    dupInsertResult <- attempt $ Mongo.insertOne col doc

    isLeft dupInsertResult `shouldEqual` true

  it "dropCollection doesn't trows if collection doesn't exist" $
    \{ db, colName, col } -> do
      res <- attempt (Mongo.dropCollection db colName)
      --let (res :: Either Unit Boolean) = Right true

      res `shouldSatisfy` isRight

  it "databaseName returns db name" \{ client } -> do
    let dbName = "other_db_name"
    db <- liftEffect $ Mongo.db client dbName

    Mongo.databaseName db `shouldEqual` dbName
    dbName `shouldEqual` dbName

  it "dropDatabase drops db" \{ db, col } -> do
    let doc = makeDoc { x: 1 }
    _ <- Mongo.insertOne col doc
    dropRes <- dropDatabase db
    count <- Mongo.countDocuments col Mongo.noFilter

    dropRes `shouldEqual` true
    count `shouldEqual` 0

  it "insertOne" $ \{ col } -> do
    let doc = makeDoc { x: 1 }
    result <- Mongo.insertOne col doc

    result.acknowledged `shouldEqual` true

  it "insertOne with _id" $ \{ col } -> do
    let _id = "my-id"
    let doc = makeDoc { x: 1, _id }
    result <- Mongo.insertOne col doc

    result.acknowledged `shouldEqual` true
    unsafeCoerce result.insertedId `shouldEqual` _id

  it "insertOne duplicate" $ \{ col } -> do
    let _id = "my-id"
    let doc = makeDoc { x: 1, _id }
    _ <- Mongo.insertOne col doc
    res <- (attempt $ Mongo.insertOne col doc)

    isLeft res `shouldEqual` true

  it "insertMany" $ \{ col } -> do
    let docs = [ makeDoc { x: 1 }, makeDoc { x: 2 } ]
    result <- Mongo.insertMany col docs

    (isJust $ Object.lookup "0" result.insertedIds) `shouldSatisfy` eq true
    (isJust $ Object.lookup "1" result.insertedIds) `shouldSatisfy` eq true

  it "findOne with noFilter/byId" $ \{ col } -> do
    let _id = "my-id"
    let doc = makeDoc { x: 1, _id }
    _ <- Mongo.insertOne col doc

    justFound <- Mongo.findOne col (Mongo.noFilter)
    foundById <- Mongo.findOne col (Mongo.byId _id)

    isJust justFound `shouldEqual` true
    isJust foundById `shouldEqual` true

  it "find with cursor to Array" $ \{ col } -> do
    let _id1 = "id1"
    let _id2 = "id2"
    let doc1 = makeDoc { x: 1, _id: _id1 }
    let doc2 = makeDoc { x: 1, _id: _id2 }
    _ <- Mongo.insertOne col doc1
    _ <- Mongo.insertOne col doc2

    foundNoFilter <-
      (liftEffect $ Mongo.find col (Mongo.noFilter))
        >>= Mongo.cursorToArray
    foundById <- (Mongo.findMany col (Mongo.byId _id1))

    Array.length foundNoFilter `shouldEqual` 2
    Array.length foundById `shouldEqual` 1
    pure unit

  it "find with cursor next" $ \{ col } -> do
    let _id1 = "id1"
    let _id2 = "id2"
    let doc1 = makeDoc { x: 1, _id: _id1 }
    let doc2 = makeDoc { x: 1, _id: _id2 }

    _ <- Mongo.insertMany col [ doc1, doc2 ]

    cursor <-
      (liftEffect $ Mongo.find col (Mongo.noFilter))
    first <- Mongo.cursorNext cursor
    second <- Mongo.cursorNext cursor
    third <- Mongo.cursorNext cursor

    isJust first `shouldEqual` true
    isJust second `shouldEqual` true
    isNothing third `shouldEqual` true

  it "replaceOne existing" $ \{ col } -> do
    let _id1 = "id1"
    let _id2 = "id2"
    let doc1 = makeDoc { x: 1, _id: _id1 }
    let doc2 = makeDoc { x: 2, _id: _id1 }

    _ <- Mongo.insertOne col doc1
    r <- Mongo.replaceOne col (Mongo.byId _id1) doc2

    r.acknowledged `shouldEqual` true
    r.modifiedCount `shouldEqual` 1
    r.matchedCount `shouldEqual` 1
    r.upsertedCount `shouldEqual` 0
    isNull r.upsertedId `shouldEqual` true

  it "findMany with options" $ \{ col } -> do
    let _id1 = "id1"
    let _id2 = "id2"
    let _id3 = "id3"
    let _id4 = "id4"
    let doc1 = makeDoc { y: 10, x: 1, _id: _id1 }
    let doc2 = makeDoc { y: 20, x: 2, _id: _id2 }
    let doc3 = makeDoc { y: 30, x: 3, _id: _id3 }
    let doc4 = makeDoc { y: 30, x: 4, _id: _id4 }

    _ <- Mongo.insertOne col doc1
    _ <- Mongo.insertOne col doc3
    _ <- Mongo.insertOne col doc4
    _ <- Mongo.insertOne col doc2

    let
      opts = _
        { limit = Just 2
        , skip = Just 1
        , sort = Just $ Object.fromFoldable [ "x" /\ -1 ]
        , projection =
            Just $ Object.fromFoldable [ "x" /\ 1 ]
        }
    found <- Mongo.findManyWith opts col (Mongo.noFilter)

    Array.length found `shouldEqual` 2
    Array.head (found <#> _.x <<< unsafeCoerce) `shouldEqual` (Just 3)
    Array.last (found <#> _.x <<< unsafeCoerce) `shouldEqual` (Just 2)
    pure unit

  it "replaceOne not existing" $ \{ col } -> do
    let _id1 = "id1"
    let _id2 = "id2"
    let doc2 = makeDoc { x: 2, _id: _id1 }

    r <- (Mongo.replaceOne col (Mongo.byId _id1) doc2)

    r.acknowledged `shouldEqual` true
    r.modifiedCount `shouldEqual` 0
    r.matchedCount `shouldEqual` 0
    r.upsertedCount `shouldEqual` 0
    isNull r.upsertedId `shouldEqual` true

  it "replaceOne not existing with upsert" \{ col } -> do
    let _id1 = "id1"
    let doc2 = makeDoc { x: 2, _id: _id1 }

    r <- Mongo.replaceOneWith (_ { upsert = true }) col (Mongo.byId _id1) doc2

    r.acknowledged `shouldEqual` true
    r.modifiedCount `shouldEqual` 0
    r.matchedCount `shouldEqual` 0
    r.upsertedCount `shouldEqual` 1
    unsafeCoerce r.upsertedId `shouldEqual` _id1

  it "deleteOne" $ \{ col } -> do
    let doc = makeDoc { x: 1 }
    { insertedId } <- Mongo.insertOne col doc
    result <- Mongo.deleteOne col (Mongo.byId insertedId)
    found <- Mongo.findOne col (Mongo.byId insertedId)

    result.acknowledged `shouldEqual` true
    result.deletedCount `shouldEqual` 1
    (found <#> const unit) `shouldEqual` Nothing

  it "deleteMany" $ \{ col } -> do

    let doc1 = makeDoc { x: 1 }
    let doc2 = makeDoc { x: 1 }
    let doc3 = makeDoc { x: 2 }

    _ <- Mongo.insertMany col [ doc1, doc2, doc3 ]

    result <- Mongo.deleteMany col (unsafeCoerce { x: 1 })
    found <- Mongo.findMany col (Mongo.noFilter)

    result.acknowledged `shouldEqual` true
    result.deletedCount `shouldEqual` 2
    (Array.length found) `shouldEqual` 1

  it "updates db with transaction" \{ client, col, db } -> do
    session <- Mongo.startSession client
    let insert = Mongo.insertOneWith _ { session = Just session } col

    r <- Mongo.withTransaction session do
      _ <- insert (makeDoc { x: 1 })
      pure { x: 1 }

    r.x `shouldEqual` 1

    Mongo.endSession session
    found <- Mongo.findOne col (filterBy { x: 1 })

    isJust found `shouldEqual` true

  it "does not update db if error occurs while transaction" \{ client, col, db } -> do
    session <- Mongo.startSession client
    let insert = Mongo.insertOneWith _ { session = Just session } col
    let
      runTrans = do
        Mongo.withTransaction session do

          _ <- insert (makeDoc { x: 1 })
          _ <- throwError (error "Transaction error")
          _ <- insert (makeDoc { x: 2 })

          pure unit

    catchError runTrans (\_ -> pure unit)

    Mongo.endSession session

    found <- Mongo.findOne col (filterBy { x: 1 })
    found2 <- Mongo.findOne col (filterBy { x: 2 })

    isJust (found2 <|> found) `shouldEqual` false

    pure unit

  it "Retrieves stored double" \{ db, col } -> do
    let doc = makeDoc { x: 1.0, _id: 1 }
    _ <- Mongo.insertOne col doc

    found <- Mongo.findOne col (Mongo.byId 1)
    let codec = object "obj" { x: numberCanonical }
    case found of
      Just docFound -> do
        let decoded = decode codec $ spy "ser" $ EJSON.serialize docFound
        isRight (spy "decoded" decoded) `shouldEqual` true

      Nothing ->
        fail (show "Not found")

intCanonical :: JsonCodec Int
intCanonical =
  prismaticCodec "Int"
    (\{ "$numberInt": str } -> Int.fromString str)
    (\num -> { "$numberInt": Int.toStringAs Int.decimal num })
    (object "EJSON.Int" { "$numberInt": C.string })

numberCanonical' :: JsonCodec Number
numberCanonical' =
  prismaticCodec "Number"
    (\{ "$numberDouble": str } -> Number.fromString str)
    (\num -> { "$numberDouble": NF.toString num })
    (object "EJSON.Number" { "$numberDouble": C.string })

numberCanonical :: JsonCodec Number
numberCanonical =
  -- If we store number as Double but it is without fraction (i.e 1.0), the
  -- driver will retrieve it as plain number (not JS Double type) and
  -- EJSON.serialize will convert it to {$numberInt: 1} (this is actually a
  -- buggy behaviour of the driver).
  codec'
    ( \j → decode doubleCodec j <#> _."$numberDouble"
        # either (\_ -> decode intCodec j <#> _."$numberInt") Right
        # either Left (maybe (Left $ UnexpectedValue j) Right <<< Number.fromString)
        # lmap (Named "Number")

    )
    (encode doubleCodec <<< \n -> { "$numberDouble": NF.toString n })

  where
  doubleCodec = (object "EJSON.Number" { "$numberDouble": C.string })
  intCodec = (object "EJSON.Number" { "$numberInt": C.string })

objectIdCanonical :: JsonCodec ObjectId
objectIdCanonical =
  prismaticCodec "ObjectId"
    (\{ "$oid": str } -> hush $ ObjectId.fromString str)
    (\id -> { "$oid": ObjectId.toString id })
    (object "EJSON.ObjectId" { "$oid": C.string })

-- Converts DateTime from/to canonical EJSON representation
-- {"$date": {"$numberLong": "<millis>"}
dateCanonical :: JsonCodec DateTime
dateCanonical =
  prismaticCodec "DateTime"
    (\{ "$date": { "$numberLong": val } } -> toDate val)
    (\dt -> { "$date": { "$numberLong": fromDate dt } })
    (object "EJSON.Date" { "$date": object "Millis" { "$numberLong": C.string } })
  where
  fromDate = NF.toStringWith (NF.fixed 0)
    <<< unwrap
    <<< Instant.unInstant
    <<< Instant.fromDateTime

  toDate millis = (Milliseconds <$> Number.fromString millis) >>= Instant.instant <#>
    Instant.toDateTime

unsafeFromJust :: forall a. Maybe a -> a
unsafeFromJust x = fromMaybe' (\_ -> unsafeCrashWith "Not Just") x

--testCodec :: ∀ a. JsonCodec a  -> a -> Boolean
testCodec :: ∀ a. Eq a => JsonCodec a -> a -> Aff Unit
testCodec codec val = do
  let encoded = encode codec val
  case EJSON.deserialize encoded of
    Right doc -> do
      let json = EJSON.serialize doc
      case decode codec json of
        Right decoded -> do
          let res = decoded == val
          res `shouldEqual` true
        Left err ->
          fail (show err)
    Left err ->
      fail (show err)

main :: Effect Unit
main = launchAff_ $ do
  runSpec [ consoleReporter ] do
    describe "MongoDb db/collection" do
      let dbName = "purescript_mongodb_test_db"
      let colName = "testCollection"
      before
        ( do
            client <- Mongo.connect $ "mongodb://localhost/" <> dbName

            db <- liftEffect $ Mongo.defaultDb client
            col <- liftEffect $ Mongo.collection db colName

            apathize $ Mongo.dropCollection db colName

            pure { client, db, col, colName }
        )
        do tests

      describeOnly "HexString" do
        it "do not make  from invalid string" do
          (HexString.toString <$> HexString.fromString "x339x") `shouldEqual` Nothing

        it "makes from valid string" do
          let valid = "507f191e810c19729de860ea"
          (HexString.toString <$> HexString.fromString valid) `shouldEqual` Just valid

        it "makes from valid string" do
          let valid = "507f191e810c19729de860ea"
          (HexString.toString <$> HexString.fromString valid) `shouldEqual` Just valid

        it "makes ObjectId from HexString" do
          let valid = "507f191e810c19729de860ea"
          (ObjectId.toString <<< ObjectId.fromHexString <$> HexString.fromString valid)
            `shouldEqual` Just valid

        it "makes valid HexString from string ignoring Hex letters case" do
          let valid = "507f191e810C19729de860eA"
          (ObjectId.toString <<< ObjectId.fromHexString <$> HexString.fromString valid)
            `shouldEqual` Just (toLower valid)

        it "makes HexString from ObjectId" do
          id <- liftEffect $ ObjectId.generate
          (HexString.toString $ ObjectId.toHexString id)
            `shouldEqual` ObjectId.toString id

      describe "EJSON Codecs" do
        it "dateCanonical" do
          now <- liftEffect $ Now.nowDateTime
          testCodec dateCanonical now
        it "objectIdCanonical" do
          id <- liftEffect $ ObjectId.generate
          testCodec objectIdCanonical id
        it "intCanonical" do
          testCodec intCanonical 10
          testCodec intCanonical (-10)
          testCodec intCanonical (0x10)

        it "numberCanonical" do
          testCodec numberCanonical 10.123
          testCodec numberCanonical (-10.0)
