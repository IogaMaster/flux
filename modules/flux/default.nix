{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.flux;
in {
  options.flux = with types; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to enable flux.
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
              default = null;
              description = lib.mdDoc ''
                Path to file containing token to use for the proxy.
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
    users.users.flux = {
      home = "/var/lib/flux";
      createHome = true;
      isSystemUser = true;
      group = "flux";
    };
    users.groups.flux = {};

    systemd.tmpfiles.rules =
      lib.mapAttrsToList
      (
        name: _: "d '/var/lib/flux/${name}' 0770 flux flux - -"
      )
      cfg.servers;

    systemd.services =
      lib.mapAttrs (name: conf: {
        description = "Flux Server ${name}";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        script = let
          proxyCommand =
            if conf.proxy.enable
            then
              if (conf.proxy.backend == "playit")
              then "${pkgs.playit}/bin/playit-cli -s &"
              else if (conf.proxy.backend == "ngrok")
              then ""
              else if (conf.proxy.backend == "cloudflare")
              then "${pkgs.cloudflared}/bin/cloudflared tunnel ${
                if (conf.proxy.tokenFile != null)
                then "--cred-file ${conf.proxy.tokenFile}"
                else ""
              } --url localhost:${conf.proxy.port} &"
              else ""
            else "";
        in ''
          ${proxyCommand}
          ${conf.package}/bin/*
        '';
        serviceConfig = {
          Nice = "-5";
          Restart = "always";
          User = "flux";
          group = "flux";
          WorkingDirectory = "/var/lib/flux";
        };
      })
      cfg.servers;
  };
}
