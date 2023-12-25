module MongoDb
  ( Client
  , Db
  , Collection
  , FindCursor
  , Document
  , InsertedId

  , FindOptions
  , defaultFindOptions

  , ReplaceOptions
  , defaultReplaceOptions

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

  , unsafeToJson
  , fromJson

  , find
  , findWithOptions

  , cursorToArray
  , cursorNext

  , findOne
  , findOneWithOptions

  , findMany
  , findManyWithOptions
  -- , findOneWithOptions
  , insertOne
  -- , insertOneWithOptions
  --, updateOne
  -- , updateOneWithOptions
  , replaceOne
  , replaceOneWithOptions

  -- , updateMany
  -- , updateManyWithOptions

  -- , insertMany
  -- , insertManyWithOptions
  -- , deleteOne
  -- , deleteMany
  -- , deleteManyWithOptions
  , module Reexport
  ) where


import Prelude

import Data.Argonaut.Core (Json)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn4, runFn1, runFn2, runFn3, runFn4)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, notNull, null, toMaybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign.Object (Object)
import MongoDb.ObjectId (ObjectId) as Reexport
import Promise.Aff (Promise, toAffE)
import Unsafe.Coerce (unsafeCoerce)


foreign import data Client :: Type
foreign import data Db :: Type
foreign import data Collection :: Type
foreign import data FindCursor :: Type


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


type ReplaceOptions = { upsert :: Boolean }


type CountDocumentsOptions = {}

--newtype SortOrder = SortOrder Int

-- asc :: String -> SortOrder
-- asc field = [ field,  1 ]

-- desc :: String -> SortOrder
-- desc field = [ field, 0 ]


type FindOptions =
  { limit :: Nullable Int
  , skip :: Nullable Int
  -- | 1 means lower will be the first in result, -1 means opposite
  , sort :: Nullable (Object Int)
  , projection :: Nullable (Object Int)
  }


defaultFindOptions :: FindOptions
defaultFindOptions =
  { limit: null
  , skip: null
  , sort: null
  , projection: null
  }


type InsertOneOptions =
  {
  }


-- We actually don't know type of insertedId
foreign import data InsertedId :: Type


type InsertOneResult =
  { acknowledged :: Boolean
  , insertedId :: InsertedId
  }


type UpdateResult =
  { acknowledged :: Boolean
  , matchedCount :: Int
  , modifiedCount :: Int
  , upsertedCount :: Int
  , upsertedId :: Nullable InsertedId
  }


defaultReplaceOptions :: ReplaceOptions
defaultReplaceOptions =
  { upsert: false
  }


-- Move to separate module.
unsafeToJson :: Document -> Json
unsafeToJson =
  unsafeCoerce


fromJson :: Json -> Document
fromJson =
  unsafeCoerce


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


countDocuments :: Collection -> Filter -> Aff Int
countDocuments col filter =
  toAffE $ runFn3 _countDocuments col filter null


findOne :: Collection -> Filter -> Aff (Maybe Document)
findOne col filter =
  map toMaybe <$> toAffE $ (runFn3 _findOne col filter null)

findOneWithOptions :: Collection -> Filter -> FindOptions -> Aff (Maybe Document)
findOneWithOptions col filter options =
  map toMaybe <$> toAffE $ (runFn3 _findOne col filter (notNull options))


insertOne :: Collection -> Document -> Aff InsertOneResult
insertOne col doc =
  toAffE $ (runFn3 _insertOne col doc null)


find :: Collection -> Filter -> Effect FindCursor
find col filter =
  runFn3 _find col filter null


findWithOptions :: Collection -> Filter -> FindOptions -> Effect FindCursor
findWithOptions col filter options =
  runFn3 _find col filter (notNull options)


findMany :: Collection -> Filter -> Aff (Array Document)
findMany col filter =
  liftEffect (find col filter) >>= cursorToArray


findManyWithOptions :: Collection -> Filter -> FindOptions -> Aff (Array Document)
findManyWithOptions col filter options =
  liftEffect (findWithOptions col filter options) >>= cursorToArray


cursorToArray :: FindCursor -> Aff (Array Document)
cursorToArray =
  toAffE <<< _cursorToArray


cursorNext :: FindCursor -> Aff (Maybe Document)
cursorNext =
  map toMaybe <$> toAffE <<< _cursorNext


replaceOne :: Collection -> Filter -> Document -> Aff UpdateResult
replaceOne col filter replacement =
  toAffE $ (runFn4 _replaceOne col filter replacement null)


replaceOneWithOptions ::
  Collection -> Filter -> Document -> ReplaceOptions -> Aff UpdateResult
replaceOneWithOptions col filter replacement options =
  toAffE $ (runFn4 _replaceOne col filter replacement (notNull options))


-- -- FOREIGN


foreign import _connect :: String -> Effect (Promise Client)
foreign import _defaultDb :: Client -> (Effect Db)
foreign import _db :: Fn2 Client String (Effect Db)
foreign import _close :: Fn1 Client (Effect (Promise Unit))


foreign import _collection :: Fn2 Db String (Effect Collection)
foreign import _dropCollection :: Fn2 Db String (Effect (Promise Boolean))
foreign import _dropDatabase :: Fn1 Db (Effect (Promise Boolean))
foreign import databaseName :: Db -> String


foreign import _createIndexes ::
  Fn2 Collection (Array IndexDescription)
    (Effect (Promise (Array IndexName)))


foreign import _countDocuments ::
  Fn3 Collection Filter (Nullable CountDocumentsOptions)
    (Effect (Promise Int))


foreign import _findOne ::
  Fn3 Collection Filter (Nullable FindOptions)
    (Effect (Promise (Nullable Document)))


foreign import _insertOne ::
  Fn3 Collection Document (Nullable InsertOneOptions)
    (Effect (Promise InsertOneResult))


foreign import _find ::
  Fn3 Collection Filter (Nullable FindOptions)
    (Effect FindCursor)


foreign import _cursorNext ::
  FindCursor -> Effect (Promise (Nullable Document))


foreign import _cursorToArray ::
  FindCursor -> Effect (Promise (Array Document))


foreign import _replaceOne ::
  Fn4 Collection Filter Document (Nullable ReplaceOptions)
    (Effect (Promise UpdateResult))


-- UTIL


compose2 :: ∀ a b x y. (a -> b) -> (x -> y -> a) -> x -> y -> b
compose2 f g x y = f (g x y)


compose3 :: ∀ a b x y z. (a -> b) -> (x -> y -> z -> a) -> x -> y -> z -> b
compose3 f g x y z = f (g x y z)


infixr 9 compose2 as <<<<
infixr 9 compose3 as <<<<<
