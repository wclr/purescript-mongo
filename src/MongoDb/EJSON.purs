module MongoDb.EJSON (serialize, deserialize) where


import Prelude

import Data.Argonaut.Core (Json)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import MongoDb (Document)


foreign import serialize :: Document -> Json


foreign import _deserialize :: Json -> Nullable Document


deserialize :: Json -> Maybe Document
deserialize = toMaybe <<< _deserialize
