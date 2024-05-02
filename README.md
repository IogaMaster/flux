<h1 align="center">Flux</h1>

<h1 align="center">
<a href='#'><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px"/></a>
  <br> <br>
  <div>
    <a href="https://github.com/IogaMaster/flux/issues">
        <img src="https://img.shields.io/github/issues/IogaMaster/flux?color=fab387&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/IogaMaster/flux/stargazers">
        <img src="https://img.shields.io/github/stars/IogaMaster/flux?color=ca9ee6&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/IogaMaster/flux">
        <img src="https://img.shields.io/github/repo-size/IogaMaster/flux?color=ea999c&labelColor=303446&style=for-the-badge">
    </a>
    <a href="https://github.com/IogaMaster/flux/blob/main/.github/LICENCE">
        <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=ca9ee6&colorA=313244&colorB=cba6f7"/>
    </a>
    <br>
    </div>
        <img href="https://builtwithnix.org" src="https://builtwithnix.org/badge.svg"/>
   </h1>
   <br>

With flux you can build servers as packages with a simple interface and deploy them with the included module.

- 🏗️ Builders that make packaging and running servers simple:
    - mkGenericServer (builder for any server)
    - mkMinecraftServer (builder for mcman based servers)
    - mkSteamServer (wrapper for steamcmd and steam-run)
- ⚙️ A module for running servers with additional tools:
    - 🏭 Runs the server
    - 🌐 Sets up proxy (playit.gg, ngrok, cloudflare tunnels)
    - 🫙 Works great on host, nixos-containers, and microvms
- 📦 Packages not present in nixpkgs (yet) that are useful for servers.
    - [mcman](https://github.com/ParadigmMC/mcman)
    - [playit](https://playit.gg/)

#### Why?

I set up servers for my friends all of the time, and I became frustrated at the amount of work it took change a vanilla minecraft server to a modded one.
So I integrated [mcman](https://github.com/ParadigmMC/mcman) to make this easy, then I decided to make servers for steam and other random projects.

## 📦 Installation and Usage

Installation is simple:

1. Add flux as an input to your flake
   ```nix
   inputs.flux.url = "github:IogaMaster/flux";
   ```
2. Add the exposed overlay to your global pkgs definition, so the builder functions are available.
   ```nix
    nixpkgs.overlays = [ flux.overlays.default ];
   ```
3. Import the NixOS module `flux.nixosModules.default` in your host config.
   ```nix
   nixosConfigurations.host1 = lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./host1/configuration.nix
        flux.nixosModules.default
      ];
   };
   ```
4. Define a server using the module.
   ```nix
   flux = {
       enable = true;
       servers = {
           vanilla-minecraft = {
               package = pkgs.mkMinecraftServer {
                  name = "myminecraftserver";
                  src = ./mcmanconfig; # Path to a mcman config
                  hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
               };
               proxy.enable = true;
           };
        };
   };
   ```

<details>
<summary>Example flake.nix</summary>

```nix
{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flux.url = "github:oddlama/nix-flux";
    flux.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-utils, nixpkgs, flux, ... }: {
    # Example. Use your own hosts and add the module to them
    nixosConfigurations.host1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
            flux = {
                enable = true;
                servers = {
                    vanilla-minecraft = {
                        package = pkgs.mkMinecraftServer {
                           name = "myminecraftserver";
                           src = ./mcmanconfig; # Path to a mcman config
                           hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
                        };
                        proxy.enable = true;
                    };
                 };
            };
        }
        flux.nixosModules.default
      ];
    };
  }
  // flake-utils.lib.eachDefaultSystem (system: rec {
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ flux.overlays.default ];
    };
  });
}
```
</details>

## 🌱 Using the builder functions:

You can create packages that run the server instead of using them in the module:

Example minecraft server:
```nix
{lib, pkgs, ... }: 
pkgs.mkMinecraftServer {
   name = "myminecraftserver";
   src = ./mcmanconfig; # Path to a mcman config
   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
```

Example generic server:
```nix
{
  lib,
  mkGenericServer,
  fetchzip,
  ...
}: 
mkGenericServer {
  name = "myserver";

  src = fetchzip {
    url = "http://www.example.org/server.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [];

  buildInputs = [];

  buildPhase = ''
    HOME=$TMPDIR

    cd $src
    cp -r . $out
  '';

  startCmd = "./start.sh";
}
```

Example steam server:
```nix
{lib, pkgs, ... }: 
pkgs.mkSteamServer rec {
   name = "mygameserver";
   src = pkgs.fetchSteam {
       inherit name;
       appId = ""; # Dedicated server app id, can be found with https://steamdb.info/
       hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
   };
   
   startCmd = "./FactoryServer.sh";

   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
```

## 🔨 TODO

There is still a lot to do.

- Examples

## ❤️ Contributing

Contributions are whole-heartedly welcome! Please feel free to suggest new features,
implement additional builders, helpers, or generally assist if you'd like. We'd be happy to have you.
There's more information in [CONTRIBUTING.md](CONTRIBUTING.md).

## 📜 License

Licensed under the MIT license ([LICENSE](LICENSE) or <https://opensource.org/licenses/MIT>).
Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in this project by you, shall be licensed as above, without any additional terms or conditions.
