module MongoDb.ObjectId
  ( ObjectId
  , generate
  , toHexString
  , fromString
  , toString
  ) where


import Prelude

import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Exception (Error)
import MongoDb.ObjectId.HexString (ValidHexString)
import MongoDb.ObjectId.HexString as HexString
import Unsafe.Coerce (unsafeCoerce)


foreign import data ObjectId :: Type


instance EncodeJson ObjectId where
  encodeJson = unsafeCoerce


instance DecodeJson ObjectId where
  decodeJson = pure <<< unsafeCoerce


instance Show ObjectId where
  show id = "[ObjectId " <> toString id <> "]"


instance Eq ObjectId where
  eq = equals


foreign import equals :: ObjectId -> ObjectId -> Boolean


{- Create ObjectId from String -}
foreign import fromString_ ::
  (Error -> Either Error ObjectId) ->
  (ObjectId -> Either Error ObjectId) ->
  String ->
  Either Error ObjectId


fromString :: String -> Either Error ObjectId
fromString s =
  fromString_ Left Right s


foreign import generate :: Effect ObjectId


foreign import toHexString :: ObjectId -> ValidHexString


toString :: ObjectId -> String
toString =
  HexString.toString <<< toHexString
