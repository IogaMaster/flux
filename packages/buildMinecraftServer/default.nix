{
  lib,
  makeWrapper,
  stdenv,
  dynamo,
  jre,
  jre8,
}: {
  name ? "",
  src ? null,
  nativeBuildInputs ? [],
  buildInputs ? [],
  meta ? {},
  ...
}:
stdenv.mkDerivation {
  name = "${name}-server";
  inherit src;

  nativeBuildInputs =
    [
      makeWrapper
    ]
    ++ nativeBuildInputs;

  buildInputs =
    [
      dynamo.mcman
      jre
      jre8
    ]
    ++ buildInputs;

  installPhase = ''
    mkdir -p $out/bin

    cat << EOF > $out/bin/start.sh
      DIRECTORY="/srv/minecraft/${name}-server"
      if [ ! -d \$DIRECTORY ]; then
          cd $src
          mkdir -p \$DIRECTORY
          mcman build -o \$DIRECTORY
      fi
      cd \$DIRECTORY
      \$(\$DIRECTORY/start.sh)
    EOF
    chmod +x $out/bin/start.sh

    wrapProgram $out/bin/start.sh \
      --prefix PATH : ${lib.makeBinPath [jre jre8]} \
  '';

  meta.mainProgram = "start.sh";
}
