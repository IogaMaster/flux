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
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin

      cat << EOF > $out/bin/runServer.sh
        DIRECTORY="${name}"

        if [ ! -d \$DIRECTORY ]; then
            mkdir -p \$DIRECTORY
        fi

        # If the DIRECTORY is not empty then run a hash check otherwise setup
        if find "\$DIRECTORY" -mindepth 1 -maxdepth 1 | read; then
          # if not empty check if the hashfile exists and matches the build hash, if it doesn't then recreate the server
          if [ -f "\$DIRECTORY/.hash" ] && ! grep -qF "${serverBuild}" "\$DIRECTORY/.hash"; then
            rm -rf \$DIRECTORY
            mkdir -p \$DIRECTORY
            cp -r ${serverBuild}/. \$DIRECTORY
          fi
        else
            cp -r ${serverBuild}/. \$DIRECTORY
        fi

        echo ${serverBuild} > \$DIRECTORY/.hash

        cd \$DIRECTORY
        ./${startCmd}
      EOF
      chmod +x $out/bin/runServer.sh

      wrapProgram $out/bin/runServer.sh \
        --prefix PATH : ${lib.makeBinPath buildInputs} \
    '';

    meta.mainProgram = "runServer.sh";
  };
in
  pkgs.buildFHSEnv {
    inherit name;
    targetPkgs = pkgs: [
      serverRuntime
    ];

    runScript = ''
      runServer.sh
    '';
  }
