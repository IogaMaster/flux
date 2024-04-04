{
  lib,
  pkgs,
}:
pkgs.dynamo.buildMinecraftServer {
  name = "blah";
  src = ./vanilla;

  hash = "sha256-/Oa8SReVhpwcgJGXCsst2FpSRZlvjcs710YypC+xyVM=";
}
