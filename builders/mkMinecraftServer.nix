{
  lib,
  mkGenericServer,
  mcman,
  jre,
  jre8,
  ...
}: {
  name ? "",
  src ? null,
  hash ? "",
  meta ? {},
  ...
}:
mkGenericServer {
  inherit name src hash;

  nativeBuildInputs = [
    mcman
    jre
    jre8
  ];

  buildInputs = [
    mcman
    jre
    jre8
  ];

  buildPhase = ''
    HOME=$TMPDIR

    cd $src
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
