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
      minecraft = listOf (import ./types/minecraft.nix);
      # steam = {};
    };
  };

  config = lib.mkIf cfg.enable {};
}
