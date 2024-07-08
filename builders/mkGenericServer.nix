{
  lib,
  stdenv,
  makeWrapper,
  buildFHSEnv,
  ...
}: {
  name ? "",
  src ? null,
  nativeBuildInputs ? [],
  buildInputs ? [],
  buildPhase ? "",
  installPhase ? "",
  startCmd ? "",
  outputHashAlgo ? "sha256",
  outputHashMode ? "recursive",
  dontPatchELF ? false,
  dontUnpack ? false,
  hash ? "",
  meta ? {},
  ...
}: let
  serverBuild = stdenv.mkDerivation {
    name = "${name}-build";
    inherit src nativeBuildInputs buildInputs buildPhase installPhase outputHashAlgo outputHashMode dontPatchELF dontUnpack;

    dontPatchShebangs = true;
    outputHash = hash;
  };

  serverRuntime = stdenv.mkDerivation {
    name = "${name}-runtime";
    inherit src buildInputs dontUnpack;

    nativeBuildInputs = [
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin

      cat << EOF > $out/bin/runServer.sh
        DIRECTORY="${name}"

        if [ ! -d \$DIRECTORY ]; then
            mkdir -p \$DIRECTORY
        fi

        cp -r ${serverBuild}/. \$DIRECTORY

        echo ${serverBuild} > \$DIRECTORY/.hash

        cd \$DIRECTORY
        chmod 755 -R .
        ${startCmd}
      EOF
      chmod +x $out/bin/runServer.sh

      wrapProgram $out/bin/runServer.sh \
        --prefix PATH : ${lib.makeBinPath buildInputs} \
    '';

    meta.mainProgram = "runServer.sh";
  };
in
  buildFHSEnv {
    inherit name;
    targetPkgs = pkgs: [
      serverRuntime
    ];

    runScript = ''
      runServer.sh
    '';
  }
