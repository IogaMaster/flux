(import ../../lib.nix) rec {
  name = "minecraft-basic";
  nodes = {
    node1 = { self, pkgs, ... }: {
      imports = [ self.nixosModules.flux ];
      nixpkgs.overlays = [ self.overlays.default ];
      environment.systemPackages = with pkgs; [ mcstatus mcman ];

      # Actual module
      flux = {
        enable = true;
        servers = {
          ${name} = {
            package = pkgs.mkMinecraftServer {
              inherit name;
              src = ./mcman_config;
              hash = "sha256-VWXMZn/JRoHcyOlx5s6ZFbpYNC/DUSk6S+guHEqNuNI=";
            };
          };
        };
      };
    };
  };
  testScript = let
    config = builtins.fromTOML (builtins.readFile ./mcman_config/server.toml);
    port = config.variables.SERVER_PORT;
    version = config.mc_version;
    # python
  in ''
    start_all()

    node1.wait_for_console_text("Done") # wait for server start
    output = node1.succeed("mcstatus 127.0.0.1:${port} status | grep version") # check if version matches expected one

    assert "${version}" in output, f"'{output}' does not contain '${version}'"

  '';
}

