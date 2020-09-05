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
            haskell-language-server."0.3.0" = args:
              (super.haskell-nix.cabalProject (args // {
                name = "haskell-language-server";
                src = super.fetchFromGitHub {
                  owner = "haskell";
                  repo = "haskell-language-server";
                  rev = "d36bb9929fdd0df76f86d3635067400272f68497";
                  sha256 =
                    "0jzj1a15wiwd4wa4wg8x0bpb57g4xrs99yp24623cjcvbarmwjgl";
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
