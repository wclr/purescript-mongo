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
  , "bifunctors"
  , "console"
  , "control"
  , "datetime"
  , "effect"
  , "either"
  , "exceptions"
  , "foreign"
  , "foreign-object"
  , "functions"
  , "maybe"
  , "nullable"
  , "prelude"
  , "record"
  , "simple-json"
  , "spec"
  , "typelevel-prelude"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
}
