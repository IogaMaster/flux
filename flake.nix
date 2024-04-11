{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});
  in rec {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          alejandra
        ];
      };
    });

    packages = forAllSystems (pkgs: {
      mcman = pkgs.callPackage ./pkgs/mcman {};
      playit = pkgs.callPackage ./pkgs/playit {};
    });

    nixosModules.flux = ./modules/flux;
    nixosModules.default = nixosModules.flux;

    overlays.default = final: prev: {
      mcman = final.callPackage ./pkgs/mcman {};
      playit = final.callPackage ./pkgs/playit {};

      mkGenericServer = final.callPackage ./builders/mkGenericServer.nix {};
      mkMinecraftServer = final.callPackage ./builders/mkMinecraftServer.nix {};
      mkSteamServer = final.callPackage ./builders/mkSteamServer.nix {};

      fetchSteam = final.callPackage ./helpers/fetchSteam {};
    };
  };
}
