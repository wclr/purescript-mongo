let mkPackage =
      https://raw.githubusercontent.com/spacchetti/spacchetti/20181209/src/mkPackage.dhall
        sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.9-20230718/packages.dhall
        sha256:661c257c997f37bba1b169020a87ae6ea08eb998e931875cb92e86ac9ea26846

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
