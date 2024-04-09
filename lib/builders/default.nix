{lib}: rec {
  mkGenericServer = pkgs: (import ./mkGenericServer.nix {inherit lib pkgs;});
  mkMinecraftServer = pkgs: (import ./mkMinecraftServer.nix {inherit lib pkgs mkGenericServer;});
}
