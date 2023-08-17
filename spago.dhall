{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, name = "mongo"
, dependencies =
  [ "aff"
  , "argonaut-codecs"
  , "argonaut-core"
  , "effect"
  , "simple-json"
  , "spec"
  , "bifunctors"
  , "console"
  , "control"
  , "datetime"
  , "either"
  , "exceptions"
  , "foreign"
  , "functions"
  , "maybe"
  , "nullable"
  , "prelude"
  , "record"
  , "typelevel-prelude"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
}
