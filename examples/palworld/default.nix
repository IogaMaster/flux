{pkgs, ...}:
pkgs.mkSteamServer rec {
  name = "palworld";
  src = pkgs.fetchSteam {
    inherit name;
    appId = "2394010";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  startCmd = "PalServer.sh";

  hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
