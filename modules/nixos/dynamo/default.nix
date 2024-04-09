{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.dynamo;
in {
  options.dynamo = with types; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to enable dynamo.
      '';
    };

    servers = mkOption {
      default = {};
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };

          package = mkPackageOption pkgs "" {};

          reverseProxy = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = lib.mdDoc ''
                Enable the reverseProxy
              '';
            };

            backend = mkOption {
              type = types.enum ["playit" "ngrok" "cloudflare"];
              default = "playit";
              description = lib.mdDoc ''
                What reverse proxy to use.
              '';
            };

            token = mkOption {
              type = types.str;
              default = "";
              description = lib.mdDoc ''
                Token to use for the reverse proxy.
                Needed for the `ngrok` and `cloudflare` backend.
              '';
            };

            port = mkOption {
              type = types.port;
              default = 25565;
              description = lib.mdDoc ''
                What port the reverse proxy will redirect traffic to.
              '';
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.dynamo = {
      home = "/var/lib/dynamo";
      createHome = true;
      isSystemUser = true;
      group = "dynamo";
    };
    users.groups.dynamo = {};

    systemd.services =
      lib.mapAttrs (name: conf: {
        name = "dynamo-${name}";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];

        script = ''
          ${conf.package}/bin/start.sh "/var/lib/dynamo/${name}"
        '';
        serviceConfig = {
          Nice = "-5";
          Restart = "always";
          User = "dynamo";
          WorkingDirectory = "/var/lib/dynamo/${name}";
        };
      })
      cfg.servers;
  };
}
