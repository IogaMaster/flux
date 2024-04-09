{
  lib,
  pkgs,
}:
lib.dynamo.mkMinecraftServer pkgs {
  name = "example-vanilla-server";
  src = ./vanilla;
  hash = "sha256-/hMf856rp/8BwgoVSPex+6y4ju+MDRDYMezAEize/E8=";
}
