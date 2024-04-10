{
  lib,
  pkgs,
  mkGenericServer,
}: {
  name ? "",
  src ? null,
  hash ? "",
  meta ? {},
  ...
}:
mkGenericServer pkgs {
  inherit name src hash;

  nativeBuildInputs = with pkgs; [
    dynamo.mcman
    jre
    jre8
  ];

  buildInputs = with pkgs; [
    dynamo.mcman
    jre
    jre8
  ];

  buildPhase = ''
    HOME=$TMPDIR

    cd $src
    mcman build -o $out
  '';

  startCmd = "start.sh";

  meta = {
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    license = lib.licenses.unfreeRedistributable;
  };
}
