{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    mcman.url = "github:deniz-blue/mcman";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
      pkgsAllSystems = function:
        forAllSystems (system: function nixpkgs.legacyPackages.${system});
    in rec {
      devShells = pkgsAllSystems (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            alejandra
            inputs.mcman.packages.${pkgs.stdenv.hostPlatform.system}.mcman
          ];
        };
      });

      packages = lib.recursiveUpdate (pkgsAllSystems
        (pkgs: { playit = pkgs.callPackage ./pkgs/playit { }; }))
        inputs.mcman.packages;

      nixosModules.flux = ./modules/flux;
      nixosModules.default = nixosModules.flux;

      overlays.default = final: prev: {
        inherit (inputs.mcman.packages.${final.stdenv.hostPlatform.system})
          mcman;
        playit = final.callPackage ./pkgs/playit { };

        mkGenericServer = final.callPackage ./builders/mkGenericServer.nix { };
        mkMinecraftServer =
          final.callPackage ./builders/mkMinecraftServer.nix { };
        mkSteamServer = final.callPackage ./builders/mkSteamServer.nix { };

        fetchSteam = final.callPackage ./helpers/fetchSteam { };
      };

      checks = forAllSystems (system:
        let
          checkArgs = {
            pkgs = nixpkgs.legacyPackages.${system};
            inherit self;
          };
        in { minecraft-basic = import ./tests/minecraft/basic checkArgs; });

    };
}
