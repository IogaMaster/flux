{
  lib,
  mkGenericServer,
  steam-run,
  ...
}: {
  name ? "",
  src ? null,
  hash ? "",
  nativeBuildInputs ? [],
  buildInputs ? [],
  buildPhase ? "",
  installPhase ? "",
  startCmd ? "",
  meta ? {},
  ...
}:
mkGenericServer {
  inherit name src hash nativeBuildInputs buildInputs buildPhase;

  installPhase = ''
    mkdir -p $out
    chmod +x ${startCmd}
    cp -r . $out
  '';

  startCmd = "${steam-run}/bin/steam-run ./${startCmd}";

  meta = {
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    license = lib.licenses.unfree;
  };
}
// {
  # Overrides
  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
}
