module MongoDb.ObjectId.HexString
  ( HexString
  , toString
  , fromString
  ) where

import Prelude

import Data.Either (hush)
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.String.Regex as Regex
import Data.String.Regex.Flags as Flags

newtype HexString = HexString String

toString :: HexString -> String
toString (HexString s) = s

fromString :: String -> Maybe HexString
fromString s | s' <- String.toLower s = do
  re <- hush (Regex.regex "^[a-fA-F0-9]{24}$" Flags.ignoreCase)
  if Regex.test re s then Just (HexString s') else Nothing