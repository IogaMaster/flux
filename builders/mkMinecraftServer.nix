{
  lib,
  mkGenericServer,
  mcman,
  jre,
  ...
}: {
  name ? "",
  src ? null,
  serverLocation ? null,
  hash ? "",
  meta ? {},
  java ? jre,
  ...
}:
mkGenericServer {
  inherit name src serverLocation hash;

  nativeBuildInputs = [
    mcman
    java
  ];

  buildInputs = [
    mcman
    java
  ];
  buildPhase =
    ''
      HOME=$TMPDIR
      CI=true # Better build logs
      cd $src
    ''
    + lib.optionalString (serverLocation != null) ''
      cd ${serverLocation}
    ''
    + ''
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
