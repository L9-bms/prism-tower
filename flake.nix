{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        { pkgs, ... }:
        {
          devShells = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              nodejs
              nodePackages.pnpm
            ];
          };

          # Provide packages.default only to allow for `nix build` in CI.
          # Because this project requires input depending on the configuration at build time,
          # the NixOS config should use inputs.prism-tower.lib.mkPackage
          # to build the package with access to the rest of the configuration.
          packages.default = self.lib.mkPackage { inherit pkgs; };
        };

      flake.lib.mkPackage =
        {
          pkgs,
          services ? [ ],
          links ? [ ],
          searchUrl ? "",
          ...
        }:
        pkgs.stdenv.mkDerivation (finalAttrs: {
          pname = "prism-tower";
          version = toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");
          src = ./.;

          nativeBuildInputs = [
            pkgs.nodejs
            pkgs.pnpmConfigHook
            pkgs.pnpm_10
          ];

          # https://nixos.org/manual/nixpkgs/unstable/#javascript-pnpm
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/node/fetch-pnpm-deps/default.nix
          pnpmInstallFlags = [ "--prod" ];
          pnpmDeps = pkgs.fetchPnpmDeps {
            fetcherVersion = 3;
            hash = "sha256-99SOCAGcQnMqOWyOnGDsTzZHtOh8ngVHmEE949H5KdQ=";
            pnpm = pkgs.pnpm_10;
            inherit (finalAttrs)
              pname
              version
              src
              pnpmInstallFlags
              ;
          };

          env = {
            SEARCH_URL = pkgs.lib.escapeShellArg searchUrl;
          };

          preBuild = ''
            echo '${builtins.toJSON services}' > public/services.json
            echo '${builtins.toJSON links}' > public/links.json
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
