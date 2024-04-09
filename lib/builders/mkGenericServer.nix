{
  lib,
  pkgs,
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
  hash ? "",
  meta ? {},
  ...
}: let
  serverBuild = pkgs.stdenv.mkDerivation {
    name = "${name}-build";
    inherit src nativeBuildInputs buildInputs buildPhase installPhase outputHashAlgo outputHashMode;

    dontPatchShebangs = true;
    outputHash = hash;
  };

  serverRuntime = pkgs.stdenv.mkDerivation {
    name = "${name}-runtime";
    inherit src buildInputs;

    nativeBuildInputs = with pkgs; [
      wrapProgram
    ];

    installPhase = ''
      mkdir -p $out/bin

      cat << EOF > $out/bin/start.sh
        if [ -n "\$1" ]; then
            DIRECTORY="\$1"
        else
            DIRECTORY="${name}"
        fi
        if [ ! -d \$DIRECTORY ]; then
            mkdir -p \$DIRECTORY
        fi

        if find "\$DIRECTORY" -mindepth 1 -maxdepth 1 | read; then
           echo "dir not empty"
        else
            cp -r ${serverBuild}/. \$DIRECTORY
        fi

        cd \$DIRECTORY
        ./${startCmd}
      EOF
      chmod +x $out/bin/start.sh

      wrapProgram $out/bin/start.sh \
        --prefix PATH : ${lib.makeBinPath buildInputs} \
    '';

    meta.mainProgram = "start.sh";
  };
in
  pkgs.buildFHSEnv {
    inherit name;
    targetPkgs = pkgs: [
      serverRuntime
    ];

    runScript = ''
      start.sh
    '';
  }
