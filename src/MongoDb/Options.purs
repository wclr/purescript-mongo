module MongoDb.Options
  ( InsertOptions()
  , defaultInsertOptions
  , UpdateOptions()
  , defaultUpdateOptions
  ) where


import Data.Maybe (Maybe(..))
import MongoDb.WriteConcern (WriteConcern)
-- import Simple.JSON (class EncodeJson, write)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)

-- | Typed options for inserting documents into a collection
newtype InsertOptions = InsertOptions
  { writeConcern :: Maybe WriteConcern
  , journaled    :: Maybe Boolean
  }


defaultInsertOptions :: InsertOptions
defaultInsertOptions = InsertOptions
  { writeConcern : Nothing
  , journaled    : Just false
  }


instance encodeJsonInsertOptions :: EncodeJson InsertOptions where
  encodeJson (InsertOptions {writeConcern, journaled}) =
    encodeJson { w: writeConcern, j: journaled }


-- | Typed options for updating documents into a collection
newtype UpdateOptions = UpdateOptions
  { writeConcern :: Maybe WriteConcern
  , journaled    :: Maybe Boolean
  , upsert       :: Maybe Boolean
  }


defaultUpdateOptions :: UpdateOptions
defaultUpdateOptions = UpdateOptions
  { writeConcern : Nothing
  , journaled    : Just false
  , upsert       : Just false
  }


instance encodeJsonUpdateOptions :: EncodeJson UpdateOptions where
  encodeJson (UpdateOptions o) =
    encodeJson { w: o.writeConcern, j: o.journaled, upsert: o.upsert }
