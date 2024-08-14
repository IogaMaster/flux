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
    CI=true # Better build logs

    cd $src
    mcman build -o server_build
    cp -r $src/server_build $out
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
