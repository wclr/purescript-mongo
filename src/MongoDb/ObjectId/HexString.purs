module MongoDb.ObjectId.HexString
  ( ValidHexString
  , toString
  ) where

import Unsafe.Coerce (unsafeCoerce)


foreign import data ValidHexString :: Type

toString :: ValidHexString -> String
toString = unsafeCoerce