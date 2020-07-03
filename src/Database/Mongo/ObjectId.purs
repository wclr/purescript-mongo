module Database.Mongo.ObjectId where

import Prelude

import Foreign (unsafeFromForeign, unsafeToForeign)
import Simple.JSON (class WriteForeign, class ReadForeign)

foreign import data ObjectId :: Type

instance writeForeignObjectId :: WriteForeign ObjectId where
  writeImpl = unsafeToForeign

instance readForeignObjectId :: ReadForeign ObjectId where
  readImpl = pure <<< unsafeFromForeign

instance showObjectId :: Show ObjectId where
  show = _show

instance eqObjectId :: Eq ObjectId where
  eq = _eq

foreign import _show :: ObjectId -> String
foreign import _eq :: ObjectId -> ObjectId -> Boolean
