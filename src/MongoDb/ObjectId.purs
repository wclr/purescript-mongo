module MongoDb.ObjectId
  ( ObjectId
  , generate
  , toHexString
  , fromString
  ) where

import Prelude

import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Effect (Effect)
import MongoDb.ObjectId.HexString (ValidHexString)
import MongoDb.ObjectId.HexString as HexString
import Unsafe.Coerce (unsafeCoerce)


foreign import data ObjectId :: Type


instance EncodeJson ObjectId where
  encodeJson = unsafeCoerce

instance DecodeJson ObjectId where
  decodeJson = pure <<< unsafeCoerce

instance Show ObjectId where
  show = HexString.toString <<< toHexString

instance Eq ObjectId where
  eq = equals


foreign import equals :: ObjectId -> ObjectId -> Boolean

{- Create ObjectId from String -}
foreign import fromString :: String -> ObjectId

foreign import generate :: Effect ObjectId

foreign import toHexString :: ObjectId -> ValidHexString
