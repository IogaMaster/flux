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
  config ? "",
  startCmd ? "",
  meta ? {},
  ...
}:
mkGenericServer {
  inherit name src hash nativeBuildInputs buildInputs buildPhase config;

  installPhase = ''
    mkdir -p $out
    chmod +x ${startCmd}
    cp -r . $out
  '';

  dontPatchELF = true; # Dynamic libraries need to be present in steam servers. Which patchelf removes.

  startCmd = "${steam-run}/bin/steam-run ./${startCmd}";

  meta = {
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    license = lib.licenses.unfree;
  };
}
