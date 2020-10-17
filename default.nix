{ sources ? import ./nix/sources.nix
, haskellNix ? import sources."haskell.nix" { }
, nixpkgsSrc ? haskellNix.sources.nixpkgs-2003, compiler ? "ghc884" }:
let
  overlays = haskellNix.nixpkgsArgs.overlays ++ [
    (self: super:
      let inherit (super) lib;
      in {
        haskell-nix = super.haskell-nix // {
          custom-tools = super.haskell-nix.custom-tools // {
            haskell-language-server."0.5.1" = args:
              (super.haskell-nix.cabalProject (args // {
                name = "haskell-language-server";
                src = super.fetchFromGitHub {
                  owner = "haskell";
                  repo = "haskell-language-server";
                  rev = "e3fe0e7546aa91e44cc56cfe8ec078a026cf533a";
                  sha256 =
                    "17nzgpiacmrvwsy2fjx6a6pcpkncqcwfhaijvajm16jpdgni8mik";
                  fetchSubmodules = true;
                };
                modules =
                  [{ packages.haskell-language-server.doCheck = false; }];
              })).haskell-language-server.components.exes.haskell-language-server;
          };
        };
      })
  ];

  pkgs = import nixpkgsSrc {
    inherit overlays;
    inherit (haskellNix.nixpkgsArgs) config;
  };

in pkgs.haskell-nix.cabalProject {
  compiler-nix-name = compiler;
  src = pkgs.haskell-nix.haskellLib.cleanGit {
    name = "haskell-nix-template";
    src = ./.;
  };
}
