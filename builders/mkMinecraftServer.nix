{ lib, mkGenericServer, mcman, jre, jre8, ... }:
{ name ? "", src ? null, serverLocation ? null, hash ? "", meta ? { }, ... }:
mkGenericServer {
  inherit name src serverLocation hash;

  nativeBuildInputs = [ mcman jre jre8 ];

  buildInputs = [ mcman jre jre8 ];

  buildPhase = ''
    HOME=$TMPDIR
    CI=true # Better build logs
    cd $src
  '' + lib.optionalString (serverLocation != null) ''
    cd ${serverLocation}
  '' + ''
    mcman build -o $out
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
