{
  lib,
  pkgs,
  ...
}:
pkgs.mkMinecraftServer {
  name = "vanilla";
  src = ./config;
  hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
