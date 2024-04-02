{
  lib,
  config,
  ...
}:
with lib;
with lib.custom; let
  minecraftServer = with types;
    submodule {
      options = {
        enable = mkEnableOption "";
        manifest = mkOpt (nullOr path) null "McMan config for this server";
        reverseProxy = mkEnableOption "Enable the playitgg reverse proxy";
      };
    };
in
  minecraftServer
