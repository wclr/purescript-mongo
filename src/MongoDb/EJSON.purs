module MongoDb.EJSON
  ( serialize
  , serializeWith
  , deserialize
  , deserializeWith
  , defaultOptions
  , Options
  ) where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn2, Fn4, runFn2, runFn4)
import Effect.Exception (Error)
import MongoDb (Document)

type Options = { relaxed :: Boolean, useBigInt64 :: Boolean }

foreign import _serialize :: Fn2 Options Document Json

foreign import _deserialize ::
  Fn4 Options Json
    (Error -> Either Error Document)
    (Document -> Either Error Document)
    (Either Error Document)

defaultOptions :: Options
defaultOptions = { relaxed: false, useBigInt64: false }

deserializeWith :: (Options -> Options) -> Json -> Either Error Document
deserializeWith with json =
  runFn4 _deserialize (with defaultOptions) json Left Right

serializeWith :: (Options -> Options) -> Document -> Json
serializeWith with = runFn2 _serialize (with defaultOptions)

--| Takes JSON with EJSON type values, convert to document object with BSON
--| native values. Returns Nothing if object can not be converted.
deserialize :: Json -> Either Error Document
deserialize = deserializeWith identity

--| Converts document to JSON compatible object by converting BSON native values
--| to EJSON type values.
serialize :: Document -> Json
serialize = serializeWith identity
