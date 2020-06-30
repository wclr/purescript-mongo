module Database.Mongo.ObjectId where

import Prelude

import Foreign (unsafeFromForeign, unsafeToForeign)
import Simple.JSON (class WriteForeign, class ReadForeign)

foreign import data ObjectId :: Type

instance writeForeignObjectId :: WriteForeign ObjectId where
  writeImpl = unsafeToForeign

instance readForeignObjectId :: ReadForeign ObjectId where
  readImpl = pure <<< unsafeFromForeign
