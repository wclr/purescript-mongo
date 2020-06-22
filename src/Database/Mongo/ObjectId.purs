module Database.Mongo.ObjectId where

import Foreign (unsafeToForeign)
import Simple.JSON (class WriteForeign, class ReadForeign)
import Unsafe.Coerce (unsafeCoerce)

foreign import data ObjectId :: Type

instance writeForeignObjectId :: WriteForeign ObjectId where
  writeImpl = unsafeToForeign

instance readForeignObjectId :: ReadForeign ObjectId where
  readImpl = unsafeCoerce
