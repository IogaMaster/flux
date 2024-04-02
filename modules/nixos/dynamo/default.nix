{
  lib,
  config,
  ...
}: let
  cfg = config.dynamo;
in {
  options.dynamo = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      SNOWFALLORG_EXAMPLE = "enabled";
    };
  };
}
