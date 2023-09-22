module Test.Main where


import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (over)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MongoDb (ObjectId, ReplaceOneOptions(..), defaultReplaceOneOptions)
import MongoDb as Mongo
import MongoDb.ObjectId as ObjectId
import MongoDb.Query (Query)
import MongoDb.Query as Q
import Test.Spec (before, beforeWith, before_, describe, describeOnly, it, itOnly, pending)
import Test.Spec.Assertions (shouldEqual)
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


-- colName :: String
-- colName = "item"


cleanUpCollection :: ∀ a. Mongo.Collection a -> Aff Unit
cleanUpCollection col =
  Mongo.deleteMany Q.empty col
    >>= \t -> pure unit


--
type XWithId =
  { x :: Int, _id :: ObjectId }


type X =
  { x :: Int }


main :: Effect Unit
main = launchAff_ $ do
  runSpec [ consoleReporter ] do
    describe "MongoDb db/collection" do
      let dbName = "purs_mongodb_test_col"

      before
        ( do
            client <- Mongo.connect $ "mongodb://localhost/" <> dbName
            let db = Mongo.defaultDb client
            let colName = "some"
            col <- Mongo.collection colName db
            pure { client, db, col, colName }

        ) do
          it "dropCollection" $ \{ col, colName, db } -> do
            -- TODO: check just insertOne {} - when updating to next driver
            _ <- Mongo.insertOne { x: 1 } col
            _ <- Mongo.dropCollection colName db
            count <- Mongo.countDocuments Q.empty col
            count `shouldEqual` 0
    -- it "dropCollection not existing" $ \{ col, colName, db } -> do
    -- -- TODO: check just insertOne {} - when updating to next driver
    --   _ <- Mongo.dropCollection colName db
    --   _ <- Mongo.dropCollection colName db
    --   pure unit

    describe "operations" do
      before
        ( do
            let colName = "some2"
            client <- (Mongo.connect "mongodb://localhost/purs_mongodb_test")
            let db = Mongo.defaultDb client
            col <- Mongo.collection colName db
            cleanUpCollection (col :: Mongo.Collection XWithId)
            pure { col, db, colName }
        )
        do
          it "insertOne/findOne" \{ col } -> do
            id <- liftEffect $ ObjectId.generate
            inserted <-
              Mongo.insertOne
                { x: 1, _id: id } col
            itemOne <-
              Mongo.findOne
                (Q.by { _id: Q.eq id }) col
            inserted `shouldEqual` ({ insertedId: id, success: true })
            itemOne `shouldEqual` (Just { x: 1, _id: id })

          it "replaceOne" \{ col } -> do
            id <- liftEffect $ ObjectId.generate
            inserted <-
              Mongo.insertOne
                { x: 1, _id: id } col
            replaced <-
              Mongo.replaceOne
                Q.empty
                { x: 2, _id: id }
                col
            itemOne <-
              Mongo.findOne
                (Q.by { _id: Q.eq id }) col
            replaced `shouldEqual` ({ success: true })
            itemOne `shouldEqual` (Just { x: 2, _id: id })

          it "replaceOne (upsert)" \{ col } -> do
            id <- liftEffect $ ObjectId.generate
            replaced <-
              Mongo.replaceOneWithOptions
                (over ReplaceOneOptions (_ { upsert = true }) defaultReplaceOneOptions)
                Q.empty
                { x: 1, _id: id }
                col
            itemOne <-
              Mongo.findOne
                (Q.by { _id: Q.eq id }) col
            replaced `shouldEqual` ({ success: true })
            itemOne `shouldEqual` (Just { x: 1, _id: id })

          it "insertMany/find" \{ db, colName } -> do
            --let db = Mongo.defaultDb client
            col <- Mongo.collection colName db
            liftEffect $ log "inserting"
            inserted <-
              Mongo.insertMany
                [ { x: 1 }, { x: 2 } ] col
            -- foundItems <-
            --   Mongo.find
            --     (Q.empty) col
            inserted `shouldEqual` ({ insertedCount: 2, success: true })
          --foundItems `shouldEqual` ([ { x: 1 }, { x: 2 } ])

          it "deleteMany" \{ db, colName } -> do
            (col' :: Mongo.Collection Json) <- Mongo.collection colName db
            --_ <- cleanUpCollection (col' :: Mongo.Collection Json)
            id <- liftEffect $ ObjectId.generate
            item <-
              Mongo.insertOne
                (encodeJson { x: 1, _id: id }) col'
            itemOne <-
              Mongo.findOne
                ((unsafeCoerce $ { _id: id }))
                --encodeJson { _id: id }
                col'
            --decoded <- pure $ decodeJson <$> itemOne
            (decodeJson <$> itemOne) `shouldEqual` Just (Right { x: 1, _id: id })
