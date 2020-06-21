module Database.Mongo
  ( Client
  , Database
  , Collection
  , Cursor
  , connect
  , defaultDb
  , db
  , close
  , collection
  , insertOne
  , find
  , findOne
  , countDocuments
  , aggregate
  , defaultFindOptions
  , defaultCountOptions
  , defaultAggregationOptions
  ) where

import Prelude

import Control.Bind (bindFlipped)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn5, Fn6, Fn7, Fn8, Fn9, runFn1, runFn2, runFn5, runFn6, runFn7, runFn8, runFn9)
import Data.Nullable (null)
import Database.Mongo.ApiCall (ApiCall)
import Database.Mongo.ApiCall as ApiCall
import Database.Mongo.Options (InsertOptions, UpdateOptions)
import Database.Mongo.Query (Query)
import Database.Mongo.Types (AggregationOptions, CountOptions, InsertWriteResult, FindOptions)
import Effect (Effect)
import Effect.Aff (Canceler, error, makeAff, nonCanceler)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Exception (Error)
import Foreign (Foreign)
import Simple.JSON (class ReadForeign, class WriteForeign, read, undefined, write)

foreign import data Client :: Type
foreign import data Database :: Type
foreign import data Collection :: Type -> Type
foreign import data Cursor :: Type

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
find :: ∀ a m. MonadAff m => ReadForeign a => Query a -> FindOptions -> Collection a -> m (Array a)
find q opts col = liftAff $ makeAff find' >>= collect
  where
    find' cb = runFn7 _find (write q) opts col noopCancel cb Left Right

-- | Fetches the first document that matches the query
findOne :: ∀ a m. MonadAff m => ReadForeign a => Query a -> Collection a -> m a
findOne q col = liftAff $ makeAff findOne'
  where
    findOne' cb =
      runFn7 _findOne (write q) undefined col noopCancel (cb <<< bindFlipped parse) Left Right
    parse = lmap (error <<< show) <<< read

-- | Inserts a single document into MongoDB
insertOne
  :: ∀ a m
   . WriteForeign a => MonadAff m
  => a
  -> InsertOptions
  -> Collection a
  -> m InsertWriteResult
insertOne j o c = liftAff $ makeAff \cb ->
  runFn8 _insert ApiCall.scalar (write j) (write o) c noopCancel cb Left Right

-- | Inserts an array of documents into MongoDB
insertMany
  :: ∀ a m
   . WriteForeign a => MonadAff m
  => Array a
  -> InsertOptions
  -> Collection a
  -> m InsertWriteResult
insertMany j o c = liftAff $ makeAff \cb ->
  runFn8 _insert ApiCall.vector (write j) (write o) c noopCancel cb Left Right

-- | Update a single document in a collection
updateOne
  :: ∀ a m
   . WriteForeign a => MonadAff m
  => Query a
  -> a
  -> UpdateOptions
  -> Collection a
  -> m InsertWriteResult
updateOne q u o c = liftAff $ makeAff \cb ->
  runFn9 _update ApiCall.scalar (write q) (write u) (write o) c noopCancel cb Left Right

-- | Update a single document in a collection
updateMany
  :: ∀ a m
   . WriteForeign a => MonadAff m
  => Query a
  -> a
  -> UpdateOptions
  -> Collection a
  -> m InsertWriteResult
updateMany q u o c = liftAff $ makeAff \cb ->
  runFn9 _update ApiCall.vector (write q) (write u) (write o) c noopCancel cb Left Right

-- | Gets the number of documents matching the filter
countDocuments :: ∀ a m. MonadAff m => Query a -> CountOptions -> Collection a -> m Int
countDocuments q o col = liftAff $ makeAff \cb ->
  runFn7 _countDocuments (write q) o col noopCancel cb Left Right

-- | WIP: implement typesafe aggregation pipelines
-- | Calculates aggregate values for the data in a collection
aggregate
  :: ∀ a m
   . ReadForeign a => MonadAff m
  => Array Foreign
  -> AggregationOptions
  -> Collection a
  -> m (Array a)
aggregate p o col = liftAff $ makeAff aggregate' >>= collect
  where
    aggregate' cb = runFn7 _aggregate p o col noopCancel cb Left Right

defaultFindOptions :: FindOptions
defaultFindOptions =
  { limit: null, skip: null, sort: null }

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

collect :: ∀ a m. ReadForeign a => MonadAff m => Cursor -> m (Array a)
collect cur = liftAff $ makeAff \cb ->
  runFn5 _collect cur noopCancel (cb <<< bindFlipped parse) Left Right
  where
    parse = lmap (error <<< show) <<< read

-- | Do nothing on cancel.
noopCancel :: forall a. a -> Canceler 
noopCancel _ = nonCanceler

foreign import _connect ::
  Fn5 String
      (Client -> Canceler)
      (Either Error Client -> Effect Unit)
      (Error -> Either Error Client)
      (Client -> Either Error Client)
      (Effect Canceler)

foreign import _defaultDb :: Fn1 Client Database
foreign import _db :: Fn3 String Foreign Client Database
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
      (Either Error Foreign -> Effect Unit)
      (Error -> Either Error Foreign)
      (Foreign -> Either Error Foreign)
      (Effect Canceler)

foreign import _collectOne ::
  Fn5 Cursor
      (Cursor -> Canceler)
      (Either Error Foreign -> Effect Unit)
      (Error -> Either Error Foreign)
      (Foreign -> Either Error Foreign)
      (Effect Canceler)

foreign import _findOne :: ∀ a.
  Fn7 Foreign
      Foreign
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Foreign -> Effect Unit)
      (Error -> Either Error Foreign)
      (Foreign -> Either Error Foreign)
      (Effect Canceler)

foreign import _find :: ∀ a.
  Fn7 Foreign
      FindOptions
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Cursor -> Effect Unit)
      (Error -> Either Error Cursor)
      (Cursor -> Either Error Cursor)
      (Effect Canceler)

foreign import _insert :: ∀ a.
  Fn8 ApiCall
      Foreign
      Foreign
      (Collection a)
      (Collection a -> Canceler)
      (Either Error InsertWriteResult -> Effect Unit)
      (Error -> Either Error Foreign)
      (Foreign -> Either Error Foreign)
      (Effect Canceler)

foreign import _update :: ∀ a.
  Fn9 ApiCall
      Foreign
      Foreign
      Foreign
      (Collection a)
      (Collection a -> Canceler)
      (Either Error InsertWriteResult -> Effect Unit)
      (Error -> Either Error Foreign)
      (Foreign -> Either Error Foreign)
      (Effect Canceler)

foreign import _countDocuments :: ∀ a.
  Fn7 Foreign
      (CountOptions)
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Int -> Effect Unit)
      (Error -> Either Error Int)
      (Int -> Either Error Int)
      (Effect Canceler)

foreign import _aggregate :: ∀ a.
  Fn7 (Array Foreign)
      (AggregationOptions)
      (Collection a)
      (Collection a -> Canceler)
      (Either Error Cursor -> Effect Unit)
      (Error -> Either Error Cursor)
      (Cursor -> Either Error Cursor)
      (Effect Canceler)
