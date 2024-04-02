{pkgs, ...}: {
  imports = [./modules/nixos/dynamo/default.nix];

  dynamo.servers.minecraft."baller" = {
    enable = true;
    manifest = null;
    reverseProxy = false;
  };
}
