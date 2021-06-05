module MongoDb.ObjectId
  ( ObjectId
  , generate
  , toHexString
  , fromString
  ) where

import Prelude

import Effect (Effect)
import Foreign (unsafeFromForeign, unsafeToForeign)
import MongoDb.ObjectId.HexString (ValidHexString)
import MongoDb.ObjectId.HexString as HexString
import Simple.JSON (class WriteForeign, class ReadForeign)

foreign import data ObjectId :: Type


instance writeForeignObjectId :: WriteForeign ObjectId where
  writeImpl = unsafeToForeign

instance readForeignObjectId :: ReadForeign ObjectId where
  readImpl = pure <<< unsafeFromForeign

instance showObjectId :: Show ObjectId where
  show = HexString.toString <<< toHexString

instance eqObjectId :: Eq ObjectId where
  eq = equals


foreign import equals :: ObjectId -> ObjectId -> Boolean

{- Create ObjectId from String -}
foreign import fromString :: String -> ObjectId

foreign import generate :: Effect ObjectId

foreign import toHexString :: ObjectId -> ValidHexString
