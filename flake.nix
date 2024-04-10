{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    steam-fetcher = {
      url = "github:nix-community/steam-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    steam-fetcher,
    ...
  }: let
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

    nixosModules.dynamo = ./modules/dynamo;
    nixosModules.default = nixosModules.dynamo;

    overlays.default = final: prev: {

      mcman = final.callPackage ./pkgs/mcman {};
      playit = final.callPackage ./pkgs/playit {};

      mkGenericServer = final.callPackage ./builders/mkGenericServer.nix {};
      mkMinecraftServer = final.callPackage ./builders/mkMinecraftServer.nix {};

      fetchSteam = final.callPackage (steam-fetcher+"/fetch-steam") {};
    };
  };
}
