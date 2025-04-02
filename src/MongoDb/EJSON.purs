module MongoDb.EJSON (serialize, deserialize) where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import MongoDb (Document)

--| Converts document to JSON compatible object by converting BSON native values
--| to EJSON type values.
foreign import serialize :: Document -> Json

foreign import _deserialize :: Json -> Nullable Document

--| Takes JSON with EJSON type values, convert to document object with BSON
--| native values. Returns Nothing if object can not be converted.
deserialize :: Json -> Maybe Document
deserialize = toMaybe <<< _deserialize
