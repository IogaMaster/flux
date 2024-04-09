{
  lib,
  inputs,
}: {
  mkMinecraftServer = pkgs: (import ./mkMinecraftServer.nix {
    inherit lib pkgs;
  });
}
