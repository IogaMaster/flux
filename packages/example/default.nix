{
  lib,
  pkgs,
}:
pkgs.dynamo.buildMinecraftServer {
  name = "blah";
  src = ./vanilla;

  hash = "";
}
