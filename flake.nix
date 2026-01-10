{
  description = "homelab dashboard";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = self.lib.mkPrismTower {
          inherit pkgs;
          services = [ ];
        };
      }
    )
    // {
      lib.mkPrismTower =
        {
          pkgs,
          services ? [ ],
        }:
        pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "prism-tower";
          version = "1.0.0";
          src = ./.;

          nativeBuildInputs = [
            pkgs.nodejs
            pkgs.pnpmConfigHook
            pkgs.pnpm
          ];

          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit (finalAttrs) pname version src;
            fetcherVersion = 3;
            hash = "sha256-KelpAxtDwtezMdEz8IKahkqRko1AMZEVoTxjxaoFtPg=";
          };

          preBuild = ''
            echo '${builtins.toJSON services}' > public/services.json
          '';

          buildPhase = ''
            runHook preBuild
            pnpm build
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r ./dist/* $out
            runHook postInstall
          '';
        });
    };
}
