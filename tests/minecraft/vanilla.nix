(import ../lib.nix) rec {
  name = "minecraft-vanilla";
  nodes = {
    node1 = { self, pkgs, mcman, ... }: {
      imports = [ self.nixosModules.flux ];
      nixpkgs.overlays = [ self.overlays.default ];
      environment.systemPackages = with pkgs; [ mcstatus mcman ];

      virtualisation.memorySize =
        2048; # minecraft needs quite a bit of ram to run a server
      virtualisation.cores = 2;

      # Actual module
      flux = {
        enable = true;
        servers = {
          ${name} = {
            package = pkgs.mkMinecraftServer {
              inherit name;
              src = "${mcman}/examples/vanilla";
              hash = "sha256-d/3pgxT9OyG+3icWtbGjA+wQ9PnAh6UQ3SW5c7qExWY=";
            };
          };
        };
      };
    };
  };
  testScript = let
    version = "1.20.1";
    # python
  in ''
    start_all()

    node1.wait_for_console_text("Done") # wait for server start
    output = node1.succeed("mcstatus 127.0.0.1:25565 status | grep version") # check if version matches expected one

    assert "${version}" in output, f"'{output}' does not contain '${version}'"

  '';
}

