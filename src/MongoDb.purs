module MongoDb
  ( Client
  , Database
  , Collection
  , Cursor
  , connect
  , defaultDb
  , db
  , close
  , collection
  , find, findWithOptions
  , findOne, findOneWithOptions
  , insertOne, insertOneWithOptions
  , updateOne, updateOneWithOptions
  , updateMany, updateManyWithOptions
  , insertMany, insertManyWithOptions
  , deleteOne, deleteMany
  , deleteManyWithOptions
  , countDocuments
  , aggregate
  , module MongoDb.Options
  , module MongoDb.Types
  , module MongoDb.ObjectId
  , module Reexport
  ) where


import Prelude

import Control.Bind (bindFlipped)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn5, Fn6, Fn7, Fn8, runFn1, runFn2, runFn5, runFn6, runFn7, runFn8)
import Data.Maybe (Maybe)
import Data.Nullable (null)
import Effect (Effect)
import Effect.Aff (Canceler, error, makeAff, nonCanceler)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Exception (Error)
import MongoDb.ObjectId (ObjectId)
import MongoDb.ObjectId (ObjectId) as Reexport
import MongoDb.Options (InsertOptions, UpdateOptions, defaultInsertOptions, defaultUpdateOptions)
import MongoDb.Query (Query)
import MongoDb.Types (AggregationOptions, CountOptions, FindOptions, InsertManyResult, InsertOneResult, RemoveOptions, UpdateResult, DeleteResult)


foreign import data Client :: Type
foreign import data Database :: Type
foreign import data Collection :: Type -> Type
foreign import data Cursor :: Type


write = encodeJson


read = decodeJson


-- | Connect to MongoDB using a url as documented at
-- | docs.mongodb.org/manual/reference/connection-string/
connect :: ∀ m . MonadAff m => String -> m Client
connect str = liftAff $ makeAff \cb ->
  runFn5 _connect str noopCancel cb Left Right


-- | Get the default database
defaultDb :: Client -> Database
defaultDb = runFn1 _defaultDb


-- | Get database from client by name
db :: String -> Client -> Database
db = runFn2 __db


-- | Close the connection to the database
close :: ∀ m . MonadAff m => Client -> m Unit
close cli = liftAff $ makeAff \cb ->
  runFn5 _close cli noopCancel cb Left Right


-- | Fetch a specific collection by name
collection :: ∀ a m. MonadAff m => String -> Database -> m (Collection a)
collection name d = liftAff $ makeAff \cb ->
  runFn6 _collection name d noopCancel cb Left Right


-- | Fetches the an array of documents that match the query
find :: ∀ a m.
  MonadAff m =>
  DecodeJson a =>
  Query a ->
  Collection a ->
  m (Array a)
find query col = findWithOptions query defaultFindOptions col


findWithOptions :: ∀ a m.
  MonadAff m =>
  DecodeJson a =>
  Query a ->
  FindOptions ->
  Collection a ->
  m (Array a)
findWithOptions q opts col = liftAff $ makeAff find' >>= collect
  where
    find' cb = runFn7 _find (write q) opts col noopCancel cb Left Right


-- | Fetches the first document that matches the query
findOne :: ∀ a m.
  MonadAff m =>
  DecodeJson a =>
  Query a ->
  Collection a ->
  m (Maybe a)
findOne q col =
  findOneWithOptions q defaultFindOptions col


-- | Fetches the first document that matches the query
findOneWithOptions :: ∀ a m.
  MonadAff m =>
  DecodeJson a =>
  Query a ->
  FindOptions ->
  Collection a ->
  m (Maybe a)

findOneWithOptions q opts col = liftAff $ makeAff findOne'
  where
    findOne' cb =
      runFn7 _findOne (write q) opts col noopCancel (cb <<< bindFlipped parse) Left Right
    parse = lmap (error <<< show) <<< read


-- | Inserts a single document into MongoDB
insertOne :: ∀ a m.
  EncodeJson a =>
  MonadAff m =>
  a ->
  Collection a ->
  m InsertOneResult
insertOne doc c =
  insertOneWithOptions doc defaultInsertOptions c


-- | Inserts a single document into MongoDB
insertOneWithOptions :: ∀ a m.
  EncodeJson a =>
  MonadAff m =>
  a ->
  InsertOptions ->
  Collection a ->
  m InsertOneResult
insertOneWithOptions doc options c =
  liftAff $ makeAff \cb ->
    runFn7 _insertOne (write doc) (write options) c noopCancel cb Left Right



-- | Inserts an array of documents into MongoDB
insertMany :: ∀ a m.
  EncodeJson a =>
  MonadAff m =>
  Array a ->
  Collection a ->
  m InsertManyResult
insertMany items col =
  insertManyWithOptions items defaultInsertOptions col


-- | Inserts an array of documents into MongoDB
insertManyWithOptions :: ∀ a m.
  EncodeJson a =>
  MonadAff m =>
  Array a ->
  InsertOptions ->
  Collection a ->
  m InsertManyResult
insertManyWithOptions items opts col = liftAff $ makeAff \cb ->
  runFn7 _insertMany (write items) (write opts) col noopCancel cb Left Right


-- | Update a single document in a collection
updateOne :: ∀ a m
   . EncodeJson a => MonadAff m
  => Query a
  -> a
  -> Collection a
  -> m UpdateResult
updateOne q u c =
  updateOneWithOptions q u defaultUpdateOptions c


-- | Update a single document in a collection
updateOneWithOptions :: ∀ a m
   . EncodeJson a => MonadAff m
  => Query a
  -> a
  -> UpdateOptions
  -> Collection a
  -> m UpdateResult
updateOneWithOptions q u o c = liftAff $ makeAff \cb ->
  runFn8 _updateOne (write q) (write u) (write o) c noopCancel cb Left Right


-- | Update a single document in a collection
updateMany :: ∀ a m.
  EncodeJson a =>
  MonadAff m =>
  Query a ->
  Array a ->
  Collection a ->
  m UpdateResult
updateMany q u c =
  updateManyWithOptions q u defaultUpdateOptions c


-- | Update a single document in a collection
updateManyWithOptions :: ∀ a m.
  EncodeJson a =>
  MonadAff m =>
  Query a ->
  Array a ->
  UpdateOptions ->
  Collection a ->
  m UpdateResult
updateManyWithOptions q u o c = liftAff $ makeAff \cb ->
  runFn8 _updateMany (write q) (write u) (write o) c noopCancel cb Left Right


deleteOne :: ∀ a m.
  MonadAff m =>
  DecodeJson a =>
  Query a ->
  InsertOptions ->
  Collection a ->
  m DeleteResult
deleteOne query opts col = liftAff $ makeAff
  \cb -> runFn7 _deleteOne (write query) opts col noopCancel cb Left Right


deleteMany :: ∀ a m.
  MonadAff m =>
  --DecodeJson a =>
  Query a ->
  Collection a ->
  m DeleteResult
deleteMany query col = liftAff $ makeAff
  \cb -> runFn7 _deleteMany (write query) defaultInsertOptions col noopCancel cb Left Right


deleteManyWithOptions :: ∀ a m.
  MonadAff m =>
  DecodeJson a =>
  Query a ->
  InsertOptions ->
  Collection a ->
  m DeleteResult
deleteManyWithOptions query opts col = liftAff $ makeAff
  \cb -> runFn7 _deleteMany (write query) opts col noopCancel cb Left Right


-- | Gets the number of documents matching the filter
countDocuments :: ∀ a m. MonadAff m => Query a -> CountOptions -> Collection a -> m Int
countDocuments q o col = liftAff $ makeAff \cb ->
  runFn7 _countDocuments (write q) o col noopCancel cb Left Right


-- | WIP: implement typesafe aggregation pipelines
-- | Calculates aggregate values for the data in a collection
aggregate :: ∀ a m.
  DecodeJson a => MonadAff m =>
  Array Json ->
  AggregationOptions ->
  Collection a ->
  m (Array a)
aggregate p o col = liftAff $ makeAff aggregate' >>= collect
  where
    aggregate' cb = runFn7 _aggregate p o col noopCancel cb Left Right


defaultFindOptions :: FindOptions
defaultFindOptions =
  { limit: null, skip: null, sort: null }


defaultRemoveOptions :: RemoveOptions
defaultRemoveOptions =
  { justOne: false }


defaultCountOptions :: CountOptions
defaultCountOptions =
  { limit: null, maxTimeMS: null, skip: null, hint: null }


defaultAggregationOptions :: AggregationOptions
defaultAggregationOptions =
  { explain: null
  , allowDiskUse: null
  , cursor: null
  , maxTimeMS: null
  , readConcern: null
  , hint: null
  }


collect :: ∀ a m.
  DecodeJson a => MonadAff m =>
  Cursor ->
  m (Array a)
collect cur = liftAff $ makeAff \cb ->
  runFn5 _collect cur noopCancel (cb <<< bindFlipped parse) Left Right
  where
    parse = lmap (error <<< show) <<< read


-- | Do nothing on cancel.
noopCancel :: forall a. a -> Canceler
noopCancel _ = nonCanceler



-- FOREIGN


foreign import _connect ::
  Fn5 String
      (Client -> Canceler)
      (Either Error Client -> Effect Unit)
      (Error -> Either Error Client)
      (Client -> Either Error Client)
      (Effect Canceler)


foreign import _defaultDb :: Fn1 Client Database
foreign import _db :: Fn3 String Json Client Database
foreign import __db :: Fn2 String Client Database


foreign import _handleParseFailure ::
  Fn3 Error
      (Client -> Canceler)
      (Error -> Effect Unit)
      (Effect Canceler)


foreign import _close ::
  Fn5 Client
      (Unit -> Canceler)
      (Either Error Unit -> Effect Unit)
      (Error -> Either Error Unit)
      (Unit -> Either Error Unit)
      (Effect Canceler)


foreign import _collection :: ∀ a.
  Fn6 String
      Database
      (Database -> Canceler)
      (Either Error (Collection a) -> Effect Unit)
      (Error -> Either Error (Collection a))
      (Collection a -> Either Error (Collection a))
      (Effect Canceler)


foreign import _collect ::
  Fn5 Cursor
      (Cursor -> Canceler)
      (Either Error Json -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _collectOne ::
  Fn5 Cursor
      (Cursor -> Canceler)
      (Either Error Json -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _findOne :: ∀ a.
  Fn7 Json
      FindOptions
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Json -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _find :: ∀ a.
  Fn7 Json
      FindOptions
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Cursor -> Effect Unit)
      (Error -> Either Error Cursor)
      (Cursor -> Either Error Cursor)
      (Effect Canceler)


foreign import _insertOne :: ∀ a.
  Fn7
      Json
      Json
      (Collection a)
      (Collection a -> Canceler)
      (Either Error InsertOneResult -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _insertMany :: ∀ a.
  Fn7
      Json
      Json
      (Collection a)
      (Collection a -> Canceler)
      (Either Error InsertManyResult -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _updateOne :: ∀ a.
  Fn8
      Json
      Json
      Json
      (Collection a)
      (Collection a -> Canceler)
      (Either Error UpdateResult -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _updateMany :: ∀ a.
  Fn8
      Json
      Json
      Json
      (Collection a)
      (Collection a -> Canceler)
      (Either Error UpdateResult -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _deleteOne :: ∀ a.
  Fn7 Json
      InsertOptions
      (Collection a)
      (Collection a -> Canceler)
      (Either Error DeleteResult -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _deleteMany :: ∀ a.
  Fn7 Json
      InsertOptions
      (Collection a)
      (Collection a -> Canceler)
      (Either Error DeleteResult -> Effect Unit)
      (Error -> Either Error Json)
      (Json -> Either Error Json)
      (Effect Canceler)


foreign import _countDocuments :: ∀ a.
  Fn7 Json
      (CountOptions)
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Int -> Effect Unit)
      (Error -> Either Error Int)
      (Int -> Either Error Int)
      (Effect Canceler)


foreign import _aggregate :: ∀ a.
  Fn7 (Array Json)
      (AggregationOptions)
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Cursor -> Effect Unit)
      (Error -> Either Error Cursor)
      (Cursor -> Either Error Cursor)
      (Effect Canceler)
