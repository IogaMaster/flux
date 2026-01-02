{ lib, mkGenericServer, mcman, jre, jre8, jq, curl, cacert, ... }:
{ name ? "", src ? null, serverLocation ? null, hash ? "", prefetchJars ? true
, meta ? { }, ... }:
mkGenericServer {
  inherit name src serverLocation hash;

  nativeBuildInputs = [
    mcman
    jre
    jre8
    jq
    curl

    # needed to pull server jar
    cacert
  ];

  buildInputs = [ mcman jre jre8 ];
  buildPhase = ''
    HOME=$TMPDIR
    CI=true # Better build logs
  '' + lib.optionalString (serverLocation != null) ''
    cd ${serverLocation}
  '' + ''
    mcman build -o $out
  '' + lib.optionalString prefetchJars
    # bash
    ''
      V=$(grep -m 1 "mc_version =" server.toml | cut -d'"' -f2 | tr -d '\r')
      DEST="$out/.fabric/server" && mkdir -p $DEST
      curl -4sf --retry 3 "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json" \
        | jq -r --arg v "$V" '.versions[] | select(.id == $v) | .url' \
        | xargs -r curl -4sf --retry 3 \
        | jq -r '.downloads.server.url' \
        | xargs -r curl -4sfLo "$DEST/$V-server.jar"
    '';

  installPhase = ''
    rm -vf $out/{,.}*.log
  '';

  startCmd = "./start.sh";

  meta = {
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    license = lib.licenses.unfreeRedistributable;
  };
}
