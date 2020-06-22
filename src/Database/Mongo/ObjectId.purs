module Database.Mongo.ObjectId where

import Prelude

import Foreign (readString, unsafeToForeign)
import Global.Unsafe (unsafeStringify)
import Simple.JSON (class WriteForeign, class ReadForeign)
import Unsafe.Coerce (unsafeCoerce)

foreign import data ObjectId :: Type

instance writeForeignObjectId :: WriteForeign ObjectId where
  writeImpl = unsafeStringify >>> unsafeToForeign

instance readForeignObjectId :: ReadForeign ObjectId where
  readImpl = readString >>> unsafeCoerce
