{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    mcman.url = "github:deniz-blue/mcman";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      forAllSystems = function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: function nixpkgs.legacyPackages.${system});
    in rec {
      devShells = forAllSystems (pkgs: {
        default =
          pkgs.mkShell { nativeBuildInputs = with pkgs; [ alejandra ]; };
      });

      packages = lib.recursiveUpdate
        (forAllSystems (pkgs: { playit = pkgs.callPackage ./pkgs/playit { }; }))
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
    };
}
