module Test.Main where


import Prelude

import Control.Alt ((<|>))
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (Aff, delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign as Foreign
import MongoDb as Mongo
import MongoDb.ObjectId as ObjectId
import MongoDb.Query (Query)
import MongoDb.Query as Q
import Simple.JSON (class WriteForeign, class ReadForeign, write)
import Test.Spec (before, describe, it, pending)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)



data IntOrBoolean
  = Int Int
  | Boolean Boolean


instance readForeign :: ReadForeign IntOrBoolean where
  readImpl f =
    Int <$> Foreign.readInt f
    <|> Boolean <$> Foreign.readBoolean f


type Inner = { number :: Number, text :: String }


type Item = { id :: Int, name :: String, inner :: Inner, da :: IntOrBoolean  }


searchQuery :: Query Item
searchQuery = Q.or
  [ Q.by { id: Q.eq 26637 }
  --, Q.by { da: Int 1 }
  , Q.by { inner: { text: Q.lte "10.0" } }
  ]


dbName = "purs_mongodb_test" :: String


colName = "item" :: String




cleanUpCollection :: ∀ a. ReadForeign a => Mongo.Collection a -> Aff Unit
cleanUpCollection col =
  Mongo.deleteMany Q.empty col
    >>= \t -> pure unit


--
connectTestDb :: Aff Unit
connectTestDb = do
  client <- Mongo.connect "mongodb://localhost/purs_mongodb_test"
  let db = Mongo.db dbName client
  col <- Mongo.collection "item" db
  id <- liftEffect $ ObjectId.generate
  _ <- liftEffect $ log $ "id:" <> show id
  --item <- Mongo.find searchQuery defaultFindOptions col
  _ <- Mongo.deleteMany Q.empty col
  item <-
    Mongo.insertOne
      {"x": 1, _id: id }
      Mongo.defaultInsertOptions col
  pure unit


--
main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  describe "MongoDb" do
    before (Mongo.connect "mongodb://localhost/purs_mongodb_test") do
      it "awesome" \client -> do
        let db = Mongo.defaultDb client
        col <- Mongo.collection "item" db
        x <- cleanUpCollection (col :: Mongo.Collection {})

        let isAwesome = true
        isAwesome `shouldEqual` true


-- main :: Effect Unit
-- main = launchAff_ $ runSpec [consoleReporter] do
--   describe "purescript-spec" do
--     describe "Attributes" do
--       it "awesome" do
--         _ <- connectTestDb
--         let isAwesome = true
--         isAwesome `shouldEqual` true
--       pending "feature complete"
--     describe "Features" do
--       it "runs in NodeJS" $ pure unit
--       it "runs in the browser" $ pure unit
--       it "supports streaming reporters" $ pure unit
--       it "supports async specs" do
--         res <- delay (Milliseconds 100.0) *> pure "Alligator"
--         res `shouldEqual` "Alligator"
--       it "is PureScript 0.12.x compatible" $ pure unit
