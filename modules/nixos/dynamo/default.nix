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
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };

          package = mkPackageOption pkgs "" {};

          proxy = {
            enable = mkOption {
              type = types.bool;
              default = false;
              description = lib.mdDoc ''
                Enable the proxy
              '';
            };

            backend = mkOption {
              type = types.enum ["playit" "ngrok" "cloudflare"];
              default = "playit";
              description = lib.mdDoc ''
                What proxy to use.
              '';
            };

            token = mkOption {
              type = types.str;
              default = "";
              description = lib.mdDoc ''
                Token to use for the proxy.
                Needed for the `ngrok` and `cloudflare` backend.
              '';
            };

            port = mkOption {
              type = types.port;
              default = 25565;
              description = lib.mdDoc ''
                What port the proxy will redirect traffic to.
              '';
            };
          };
        };
      });
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

    systemd.tmpfiles.rules =
      lib.mapAttrsToList
      (
        name: _: "d '/var/lib/dynamo/${name}' 0770 dynamo dynamo - -"
      )
      cfg.servers;

    systemd.services =
      lib.mapAttrs (name: conf: {
        description = "Dynamo Server ${name}";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        script = ''
          ${conf.package}/bin/start.sh
        '';
        serviceConfig = {
          Nice = "-5";
          Restart = "always";
          User = "dynamo";
          group = "dynamo";
          WorkingDirectory = "/var/lib/dynamo";

          # Hardening
          CapabilityBoundingSet = [""];
          DeviceAllow = [""];
          LockPersonality = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          UMask = "0007";
        };
      })
      cfg.servers;
  };
}
