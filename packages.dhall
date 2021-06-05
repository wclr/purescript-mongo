let mkPackage =
      https://raw.githubusercontent.com/spacchetti/spacchetti/20181209/src/mkPackage.dhall sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.0-20210329/packages.dhall sha256:32c90bbcd8c1018126be586097f05266b391f6aea9125cf10fba2292cb2b8c73

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
