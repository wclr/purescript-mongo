module MongoDb.ObjectId
  ( ObjectId
  , generate
  , toHexString
  , fromString
  ) where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Effect (Effect)
import Foreign (unsafeFromForeign, unsafeToForeign)
import MongoDb.ObjectId.HexString (ValidHexString)
import MongoDb.ObjectId.HexString as HexString
import Unsafe.Coerce (unsafeCoerce)


foreign import data ObjectId :: Type


instance writeForeignObjectId :: EncodeJson ObjectId where
  encodeJson = unsafeCoerce

instance readForeignObjectId :: DecodeJson ObjectId where
  decodeJson = pure <<< unsafeCoerce

instance showObjectId :: Show ObjectId where
  show = HexString.toString <<< toHexString

instance eqObjectId :: Eq ObjectId where
  eq = equals


foreign import equals :: ObjectId -> ObjectId -> Boolean

{- Create ObjectId from String -}
foreign import fromString :: String -> ObjectId

foreign import generate :: Effect ObjectId

foreign import toHexString :: ObjectId -> ValidHexString
