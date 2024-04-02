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
      };
    };
in
  minecraftServer
