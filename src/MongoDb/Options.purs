module MongoDb.Options
  ( InsertOptions(..)
  , defaultInsertOptions
  , UpdateOptions(..)
  , defaultUpdateOptions
  , ReplaceOneOptions(..)
  , defaultReplaceOneOptions
  ) where


import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import MongoDb.WriteConcern (WriteConcern)


-- | Typed options for inserting documents into a collection
newtype InsertOptions = InsertOptions
  { writeConcern :: Maybe WriteConcern
  , journaled :: Maybe Boolean
  }

derive instance Newtype InsertOptions _

newtype ReplaceOneOptions = ReplaceOneOptions
  { writeConcern :: Maybe WriteConcern
  , journaled :: Maybe Boolean
  , bypassDocumentValidation :: Boolean
  , upsert :: Boolean
  }

derive instance Newtype ReplaceOneOptions _

defaultInsertOptions :: InsertOptions
defaultInsertOptions = InsertOptions
  { writeConcern: Nothing
  , journaled: Just false
  }



defaultReplaceOneOptions :: ReplaceOneOptions
defaultReplaceOneOptions = ReplaceOneOptions
  { writeConcern: Nothing
  , journaled: Just false
  , bypassDocumentValidation: false
  , upsert: false
  }


instance EncodeJson ReplaceOneOptions where
  encodeJson
    ( ReplaceOneOptions
        { writeConcern
        , journaled
        , upsert
        , bypassDocumentValidation
        }
    ) =
    encodeJson
      { writeConcern: { w: writeConcern, j: journaled }
      , upsert: upsert
      , bypassDocumentValidation
      }


instance EncodeJson InsertOptions where
  encodeJson (InsertOptions { writeConcern, journaled }) =
    encodeJson
      { writeConcern: { w: writeConcern, j: journaled }
      }


-- | Typed options for updating documents into a collection
newtype UpdateOptions = UpdateOptions
  { writeConcern :: Maybe WriteConcern
  , journaled :: Maybe Boolean
  , upsert :: Maybe Boolean
  }

derive instance Newtype UpdateOptions _

defaultUpdateOptions :: UpdateOptions
defaultUpdateOptions = UpdateOptions
  { writeConcern: Nothing
  , journaled: Just false
  , upsert: Just false
  }


instance EncodeJson UpdateOptions where
  encodeJson (UpdateOptions o) =
    encodeJson
      { writeConcern: { w: o.writeConcern, j: o.journaled }
      , upsert: o.upsert
      }
