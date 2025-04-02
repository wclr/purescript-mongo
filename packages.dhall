let mkPackage =
      https://raw.githubusercontent.com/spacchetti/spacchetti/20181209/src/mkPackage.dhall
        sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.15-20241207/packages.dhall
        sha256:604d38aa63b48c64f22747beba7e198b7bde7a645de7f9ddac1d023fd4ea72a8

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
