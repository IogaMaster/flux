{pkgs, ...}:
pkgs.mkSteamServer rec {
  name = "satisfactory";
  src = pkgs.fetchSteam {
    inherit name;
    appId = "1690800";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  startCmd = "FactoryServer.sh";

  hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
