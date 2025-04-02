module MongoDb
  ( Client
  , ClientSession
  , Db
  , Collection
  , FindCursor
  , Document
  , InsertedId

  , OperationOptions

  , FindOptions
  , defaultFindOptions

  , ReplaceOptions
  , defaultReplaceOptions

  , DeleteOptions
  , defaultDeleteOptions

  , Filter

  , noFilter
  , byId

  , connect
  , defaultDb
  , db
  , close
  , collection
  , dropCollection
  , dropDatabase
  , createIndexes

  , databaseName

  , countDocuments
  , countDocumentsWith

  , find
  , findWith

  , cursorToArray
  , cursorNext

  , findOne
  , findOneWith

  , findMany
  , findManyWith
  , insertOne
  , insertOneWith

  , insertMany
  , insertManyWith

  , replaceOne
  , replaceOneWith

  -- , updateMany
  -- , updateManyWithOptions

  , deleteOne
  , deleteOneWith
  , deleteMany
  , deleteManyWith

  , startSession
  , endSession
  , withTransaction

  , module Reexport
  ) where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn4, runFn1, runFn2, runFn3, runFn4)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, notNull, null, toMaybe, toNullable)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign.Object (Object)
import Heterogeneous.Mapping (class Mapping, hmap)
import MongoDb.ObjectId (ObjectId) as Reexport
import Promise.Aff (Promise, fromAff, toAffE)
import Unsafe.Coerce (unsafeCoerce)

foreign import data Client :: Type
foreign import data Db :: Type
foreign import data Collection :: Type
foreign import data FindCursor :: Type
foreign import data ClientSession :: Type

-- | Document is type containing JS representation of MongoDb object content.
foreign import data Document :: Type

data Filter = Filter

noFilter :: Filter
noFilter = Filter

byId :: ∀ id. id -> Filter
byId _id = unsafeCoerce { _id }

-- IndexDirection = -1 | 1 | '2d' | '2dsphere' | 'text' | 'geoHaystack' | 'hashed' | number;
type IndexDirection = Int
type IndexName = String

type IndexDescription =
  { name :: IndexName
  , unique :: Boolean
  , key :: Object IndexDirection
  }

type ClientSessionOptions = {}
type EndSessionOptions = {}
type TransactionOptions = {}

data ToNullable = ToNullable

instance Mapping ToNullable (Maybe n) (Nullable n) where
  mapping ToNullable = toNullable

else instance Mapping ToNullable n n where
  mapping ToNullable = identity

type OperationOptions = (session :: Maybe ClientSession)

type OperationOptions_ = (session :: Nullable ClientSession)
--

type FindOptions =
  { limit :: Maybe Int
  , skip :: Maybe Int
  , sort :: Maybe (Object Int)
  , projection :: Maybe (Object Int)
  | OperationOptions
  }

defaultFindOptions :: FindOptions
defaultFindOptions =
  { limit: Nothing
  , skip: Nothing
  , sort: Nothing
  , projection: Nothing
  , session: Nothing
  }

type FindOptions_ =
  { limit :: Nullable Int
  , skip :: Nullable Int
  , sort :: Nullable (Object Int)
  , projection :: Nullable (Object Int)
  | OperationOptions_
  }

toFindOptions_ :: FindOptions -> FindOptions_
toFindOptions_ = hmap ToNullable

--

type ReplaceOptions =
  { upsert :: Boolean
  | OperationOptions
  }

defaultReplaceOptions :: ReplaceOptions
defaultReplaceOptions =
  { upsert: false
  , session: Nothing
  }

type ReplaceOptions_ =
  { upsert :: Boolean
  | OperationOptions_
  }

toReplaceOptions_ :: ReplaceOptions -> ReplaceOptions_
toReplaceOptions_ = hmap ToNullable

--

type InsertOneOptions =
  { | OperationOptions
  }

type InsertOneOptions_ =
  { | OperationOptions_
  }

type DeleteOptions =
  { | OperationOptions
  }

type DeleteOptions_ =
  { | OperationOptions_
  }

defaultDeleteOptions :: DeleteOptions
defaultDeleteOptions =
  { session: Nothing
  }

defaultInsertOneOptions :: InsertOneOptions
defaultInsertOneOptions =
  { session: Nothing
  }

type InsertManyOptions =
  { | OperationOptions
  }

defaultInsertManyOptions :: InsertManyOptions
defaultInsertManyOptions =
  { session: Nothing
  }

type InsertManyOptions_ =
  { | OperationOptions_
  }

toDeleteOptions_ :: DeleteOptions -> DeleteOptions_
toDeleteOptions_ = hmap ToNullable

toInsertOneOptions_ :: InsertOneOptions -> InsertOneOptions_
toInsertOneOptions_ = hmap ToNullable

toBulkWriteOptions_ :: InsertManyOptions -> InsertManyOptions_
toBulkWriteOptions_ = hmap ToNullable

-- We actually don't know type of insertedId
foreign import data InsertedId :: Type

type InsertOneResult =
  { acknowledged :: Boolean
  , insertedId :: InsertedId
  }

type DeleteResult =
  { acknowledged :: Boolean
  , deletedCount :: Int
  }

type InsertManyResult =
  { acknowledged :: Boolean
  , insertedCount :: Int
  , insertedIds :: Object InsertedId
  }

type UpdateResult =
  { acknowledged :: Boolean
  , matchedCount :: Int
  , modifiedCount :: Int
  , upsertedCount :: Int
  , upsertedId :: Nullable InsertedId
  }

type With a = a -> a

-- CLIENT METHODS

-- | Connect to MongoDB using a url as documented at
-- | https://docs.mongodb.org/manual/reference/connection-string/
connect :: String -> Aff Client
connect =
  toAffE <<< _connect

-- | Create a new Db instance sharing the current socket connections.
defaultDb :: Client -> Effect Db
defaultDb =
  runFn1 _defaultDb

-- | Create a new Db instance sharing the current socket connections.
db :: Client -> String -> Effect Db
db =
  runFn2 _db

-- | Close the connection to the database
close :: Client -> Aff Unit
close =
  toAffE <<< runFn1 _close

-- | Fetch a specific collection by name.
collection :: Db -> String -> Effect (Collection)
collection =
  runFn2 _collection

-- | Drop existing collection. Will throw if collection doesn't exist.
dropCollection :: Db -> String -> Aff Boolean
dropCollection =
  toAffE <<<< runFn2 _dropCollection

dropDatabase :: Db -> Aff Boolean
dropDatabase =
  toAffE <<< runFn1 _dropDatabase

-- | Inserts a single document into MongoDB
createIndexes :: Collection -> Array IndexDescription -> Aff (Array String)
createIndexes =
  toAffE <<<< runFn2 _createIndexes

type CountDocumentsOptions =
  { skip :: Maybe Int
  , limit :: Maybe Int
  | OperationOptions
  }

type CountDocumentsOptions_ =
  { skip :: Nullable Int
  , limit :: Nullable Int
  | OperationOptions_
  }

defaultCountDocumentsOptions :: CountDocumentsOptions
defaultCountDocumentsOptions =
  { skip: Nothing
  , limit: Nothing
  , session: Nothing
  }

toCountDocumentsOptions_ :: CountDocumentsOptions -> CountDocumentsOptions_
toCountDocumentsOptions_ = hmap ToNullable

countDocuments :: Collection -> Filter -> Aff Int
countDocuments col filter =
  toAffE $ runFn3 _countDocuments col filter null

countDocumentsWith :: With CountDocumentsOptions -> Collection -> Filter -> Aff Int
countDocumentsWith with col filter =
  toAffE $ runFn3 _countDocuments col filter
    $ notNull
    $ toCountDocumentsOptions_
    $ with defaultCountDocumentsOptions

findOne :: Collection -> Filter -> Aff (Maybe Document)
findOne col filter =
  map toMaybe <$> toAffE $ (runFn3 _findOne col filter null)

insertOne :: Collection -> Document -> Aff InsertOneResult
insertOne col doc =
  toAffE $ (runFn3 _insertOne col doc null)

insertOneWith ::
  With InsertOneOptions -> Collection -> Document -> Aff InsertOneResult
insertOneWith with col doc =
  toAffE $ runFn3 _insertOne col doc
    $ notNull
    $ toInsertOneOptions_
    $ with defaultInsertOneOptions

insertMany :: Collection -> Array Document -> Aff InsertManyResult
insertMany col docs =
  toAffE $ (runFn3 _insertMany col docs null)

insertManyWith ::
  With InsertManyOptions -> Collection -> Array Document -> Aff InsertManyResult
insertManyWith with col docs =
  toAffE $ runFn3 _insertMany col docs
    $ notNull
    $ toBulkWriteOptions_
    $ with defaultInsertManyOptions

find :: Collection -> Filter -> Effect FindCursor
find col filter =
  runFn3 _find col filter null

findWith :: With FindOptions -> Collection -> Filter -> Effect FindCursor
findWith options col filter =
  runFn3 _find col filter
    (notNull $ toFindOptions_ $ options defaultFindOptions)

findOneWith :: With FindOptions -> Collection -> Filter -> Aff (Maybe Document)
findOneWith with col filter =
  map toMaybe <$> toAffE $
    runFn3 _findOne col filter
      (notNull $ toFindOptions_ $ with defaultFindOptions)

findMany :: Collection -> Filter -> Aff (Array Document)
findMany col filter =
  liftEffect (find col filter) >>= cursorToArray

findManyWith :: With FindOptions -> Collection -> Filter -> Aff (Array Document)
findManyWith options col filter =
  liftEffect (findWith options col filter) >>= cursorToArray

cursorToArray :: FindCursor -> Aff (Array Document)
cursorToArray =
  toAffE <<< _cursorToArray

cursorNext :: FindCursor -> Aff (Maybe Document)
cursorNext =
  map toMaybe <$> toAffE <<< _cursorNext

replaceOne :: Collection -> Filter -> Document -> Aff UpdateResult
replaceOne col filter replacement =
  toAffE $ (runFn4 _replaceOne col filter replacement null)

replaceOneWith ::
  With ReplaceOptions -> Collection -> Filter -> Document -> Aff UpdateResult
replaceOneWith with col filter replacement =
  toAffE $
    runFn4 _replaceOne col filter replacement
      (notNull $ toReplaceOptions_ $ with defaultReplaceOptions)

deleteOne :: Collection -> Filter -> Aff DeleteResult
deleteOne col filter =
  toAffE $ (runFn3 _deleteOne col filter null)

deleteOneWith :: With DeleteOptions -> Collection -> Filter -> Aff DeleteResult
deleteOneWith with col filter =
  toAffE $ runFn3 _deleteOne col filter
    (notNull $ toDeleteOptions_ $ with defaultDeleteOptions)

deleteMany :: Collection -> Filter -> Aff DeleteResult
deleteMany col filter =
  toAffE $ (runFn3 _deleteMany col filter null)

deleteManyWith :: With DeleteOptions -> Collection -> Filter -> Aff DeleteResult
deleteManyWith with col filter =
  toAffE $ runFn3 _deleteMany col filter
    (notNull $ toDeleteOptions_ $ with defaultDeleteOptions)

startSession :: Client -> Aff ClientSession
startSession client =
  liftEffect $ runFn2 _startSession client null

endSession :: ClientSession -> Aff Unit
endSession session =
  liftEffect $ runFn2 _endSession session null

withTransaction :: ClientSession -> Aff Unit -> Aff Unit
withTransaction session action =
  toAffE $
    runFn3 _withTransaction session (fromAff action) null

-- -- FOREIGN

foreign import _connect :: String -> Effect (Promise Client)
foreign import _defaultDb :: Client -> (Effect Db)
foreign import _db :: Fn2 Client String (Effect Db)
foreign import _close :: Fn1 Client (Effect (Promise Unit))

foreign import _collection :: Fn2 Db String (Effect Collection)
foreign import _dropCollection :: Fn2 Db String (Effect (Promise Boolean))
foreign import _dropDatabase :: Fn1 Db (Effect (Promise Boolean))
foreign import databaseName :: Db -> String

foreign import _startSession ::
  Fn2 Client (Nullable ClientSessionOptions) (Effect ClientSession)

foreign import _endSession ::
  Fn2 ClientSession (Nullable EndSessionOptions) (Effect Unit)

foreign import _withTransaction ::
  Fn3 ClientSession
    (Effect (Promise Unit))
    (Nullable TransactionOptions)
    (Effect (Promise Unit))

foreign import _createIndexes ::
  Fn2 Collection (Array IndexDescription)
    (Effect (Promise (Array IndexName)))

foreign import _countDocuments ::
  Fn3 Collection Filter (Nullable CountDocumentsOptions_)
    (Effect (Promise Int))

foreign import _find ::
  Fn3 Collection Filter (Nullable FindOptions_)
    (Effect FindCursor)

foreign import _cursorNext ::
  FindCursor -> Effect (Promise (Nullable Document))

foreign import _cursorToArray ::
  FindCursor -> Effect (Promise (Array Document))

foreign import _findOne ::
  Fn3 Collection Filter (Nullable FindOptions_)
    (Effect (Promise (Nullable Document)))

foreign import _insertOne ::
  Fn3 Collection Document (Nullable InsertOneOptions_)
    (Effect (Promise InsertOneResult))

foreign import _insertMany ::
  Fn3 Collection (Array Document) (Nullable InsertManyOptions_)
    (Effect (Promise InsertManyResult))

foreign import _replaceOne ::
  Fn4 Collection Filter Document (Nullable ReplaceOptions_)
    (Effect (Promise UpdateResult))

foreign import _deleteOne ::
  Fn3 Collection Filter (Nullable DeleteOptions_)
    (Effect (Promise DeleteResult))

foreign import _deleteMany ::
  Fn3 Collection Filter (Nullable DeleteOptions_)
    (Effect (Promise DeleteResult))

-- UTIL

compose2 :: ∀ a b x y. (a -> b) -> (x -> y -> a) -> x -> y -> b
compose2 f g x y = f (g x y)

infixr 9 compose2 as <<<<
