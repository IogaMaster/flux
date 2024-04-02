{
  lib,
  config,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.dynamo;
in {
  options.dynamo = with types; {
    enable = mkEnableOption "Enable dynamo";

    servers = {
      # generic = {};
      minecraft = mkOpt (nullOr (listOf (import ./types/minecraft.nix))) null "";
      # steam = {};
    };
  };

  config = lib.mkIf cfg.enable {};
}
