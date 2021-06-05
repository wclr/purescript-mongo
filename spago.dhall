{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, name = "mongo"
, dependencies =
  [ "aff"
  , "argonaut-core"
  , "effect"
  , "node-process"
  , "psci-support"
  , "simple-json"
  , "spec"
  ]
, packages = ./packages.dhall
}
