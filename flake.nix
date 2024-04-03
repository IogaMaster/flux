{
  description = "My NixOS modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    steam-fetcher = {
      url = "github:nix-community/steam-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcman = {
      url = "github:ParadigmMC/mcman";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.;

      snowfall = {
        meta = {
          name = "dynamo";
          title = "dynamo";
        };

        namespace = "dynamo";
      };
      flake = {
        nixosModules.dynamo = import ./modules/dynamo;
      };
    };
}
