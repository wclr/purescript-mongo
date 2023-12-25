module Test.Main where


import Prelude

import Data.Argonaut.Encode (encodeJson)
import Data.Array as Array
import Data.Either (isLeft, isRight)
import Data.Maybe (Maybe(..), isJust, isNothing)
import Data.Nullable (notNull, null, toMaybe)
import Data.Tuple.Nested ((/\))
import Debug (spy)
import Effect (Effect)
import Effect.Aff (Aff, apathize, attempt, launchAff_)
import Effect.Class (liftEffect)
import Foreign.Object as Object
import MongoDb (dropDatabase)
import MongoDb as Mongo
import MongoDb.ObjectId (ObjectId)
import MongoDb.Query (Query)
import MongoDb.Query as Q
import Test.Spec (SpecT, before, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldSatisfy)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Unsafe.Coerce (unsafeCoerce)


-- data IntOrBoolean
--   = Int Int
--   | Boolean Boolean


-- instance readForeign :: ReadForeign IntOrBoolean where
--   readImpl f =
--     Int <$> Foreign.readInt f
--     <|> Boolean <$> Foreign.readBoolean f


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


isNull = isNothing <<< toMaybe


tests :: forall m. Monad m => SpecT Aff TestParams m Unit
tests | test <- it = do
  it "createIndex unique" $ \{ col } -> do
    let indexKey = Object.fromFoldable [ "x" /\ 1 ]
    result <- Mongo.createIndexes col
      [ { name: "my-index", unique: true, key: indexKey } ]

    result `shouldEqual` [ "my-index" ]

    let doc = Mongo.fromJson (encodeJson { x: 1 })
    _ <- Mongo.insertOne col doc
    dupInsertResult <- attempt $ Mongo.insertOne col doc

    isLeft dupInsertResult `shouldEqual` true

  it "dropCollection should trow if collection doesn't exist" $ \{ db, colName } -> do
    res <- attempt (Mongo.dropCollection db colName)

    res `shouldSatisfy` isLeft

  test "db and databaseName" \{ client } -> do
    let dbName = "other_db_name"
    db <- liftEffect $ Mongo.db client dbName

    Mongo.databaseName db `shouldEqual` dbName
    dbName `shouldEqual` dbName

  test "dropDatabase" \{ db, col } -> do
    let doc = Mongo.fromJson (encodeJson { x: 1 })
    _ <- Mongo.insertOne col doc
    dropRes <- dropDatabase db
    count <- Mongo.countDocuments col Mongo.noFilter

    dropRes `shouldEqual` true
    count `shouldEqual` 0

  it "insertOne" $ \{ col } -> do
    let doc = Mongo.fromJson (encodeJson { x: 1 })
    result <- Mongo.insertOne col doc

    result.acknowledged `shouldEqual` true

  it "insertOne with _id" $ \{ col } -> do
    let _id = "my-id"
    let doc = Mongo.fromJson (encodeJson { x: 1, _id })
    result <- Mongo.insertOne col doc

    result.acknowledged `shouldEqual` true
    unsafeCoerce result.insertedId `shouldEqual` _id

  it "insertOne duplicate" $ \{ col } -> do
    let _id = "my-id"
    let doc = Mongo.fromJson (encodeJson { x: 1, _id })
    _ <- Mongo.insertOne col doc
    res <- (attempt $ Mongo.insertOne col doc)

    isLeft res `shouldEqual` true

  it "findOne with noFilter/byId" $ \{ col } -> do
    let _id = "my-id"
    let doc = Mongo.fromJson (encodeJson { x: 1, _id })
    _ <- Mongo.insertOne col doc

    justFound <- Mongo.findOne col (Mongo.noFilter)
    foundById <- Mongo.findOne col (Mongo.byId _id)

    isJust justFound `shouldEqual` true
    isJust foundById `shouldEqual` true

  it "find with cursor to Array" $ \{ col } -> do
    let _id1 = "id1"
    let _id2 = "id2"
    let doc1 = Mongo.fromJson (encodeJson { x: 1, _id: _id1 })
    let doc2 = Mongo.fromJson (encodeJson { x: 1, _id: _id2 })
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
    let doc1 = Mongo.fromJson (encodeJson { x: 1, _id: _id1 })
    let doc2 = Mongo.fromJson (encodeJson { x: 1, _id: _id2 })
    _ <- Mongo.insertOne col doc1
    _ <- Mongo.insertOne col doc2

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
    let doc1 = Mongo.fromJson (encodeJson { x: 1, _id: _id1 })
    let doc2 = Mongo.fromJson (encodeJson { x: 2, _id: _id1 })

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
    let doc1 = Mongo.fromJson (encodeJson { y: 10, x: 1, _id: _id1 })
    let doc2 = Mongo.fromJson (encodeJson { y: 20, x: 2, _id: _id2 })
    let doc3 = Mongo.fromJson (encodeJson { y: 30, x: 3, _id: _id3 })
    let doc4 = Mongo.fromJson (encodeJson { y: 30, x: 4, _id: _id4 })

    _ <- Mongo.insertOne col doc1
    _ <- Mongo.insertOne col doc3
    _ <- Mongo.insertOne col doc4
    _ <- Mongo.insertOne col doc2

    found <- Mongo.findManyWithOptions col (Mongo.noFilter)
      $ Mongo.defaultFindOptions
          { limit = notNull 2
          , skip = notNull 1
          , sort = notNull $ Object.fromFoldable [ "x" /\ -1 ]
          , projection =
              notNull $ Object.fromFoldable [ "x" /\ 1 ]
          }

    Array.length found `shouldEqual` 2
    Array.head (found <#> _.x <<< unsafeCoerce) `shouldEqual` (Just 3)
    Array.last (found <#> _.x <<< unsafeCoerce) `shouldEqual` (Just 2)
    pure unit

  it "replaceOne not existing" $ \{ col } -> do
    let _id1 = "id1"
    let _id2 = "id2"
    let doc2 = Mongo.fromJson (encodeJson { x: 2, _id: _id1 })

    r <- (Mongo.replaceOne col (Mongo.byId _id1) doc2)

    r.acknowledged `shouldEqual` true
    r.modifiedCount `shouldEqual` 0
    r.matchedCount `shouldEqual` 0
    r.upsertedCount `shouldEqual` 0
    isNull r.upsertedId `shouldEqual` true

  it "replaceOne not existing with upsert" $ \{ col } -> do
    let _id1 = "id1"
    let doc2 = Mongo.fromJson (encodeJson { x: 2, _id: _id1 })

    r <- Mongo.replaceOneWithOptions col (Mongo.byId _id1) doc2
      (Mongo.defaultReplaceOptions { upsert = true })

    r.acknowledged `shouldEqual` true
    r.modifiedCount `shouldEqual` 0
    r.matchedCount `shouldEqual` 0
    r.upsertedCount `shouldEqual` 1
    unsafeCoerce r.upsertedId `shouldEqual` _id1


main :: Effect Unit
main = launchAff_ $ do
  runSpec [ consoleReporter ] do
    describe "MongoDb db/collection" do
      let dbName = "purs_mongodb_test_col"
      let colName = "some"
      before
        ( do
            client <- Mongo.connect $ "mongodb://localhost/" <> dbName

            db <- liftEffect $ Mongo.defaultDb client
            col <- liftEffect $ Mongo.collection db colName

            apathize $ Mongo.dropCollection db colName

            pure { client, db, col, colName }
        ) do tests
