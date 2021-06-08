module MongoDb.WriteConcern where

import Data.Argonaut.Encode (class EncodeJson)
import Unsafe.Coerce (unsafeCoerce)

foreign import data WriteConcern :: Type

nNodes :: Int -> WriteConcern
nNodes = unsafeCoerce

noAck :: WriteConcern
noAck = nNodes 0

oneAck :: WriteConcern
oneAck = nNodes 1

majority :: WriteConcern
majority = unsafeCoerce "majority"

instance encodeWriteConcern :: EncodeJson WriteConcern where
  encodeJson = unsafeCoerce
