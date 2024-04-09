{
  lib,
  pkgs,
}: {
  name ? "",
  src ? null,
  hash ? "",
  meta ? {},
  ...
}: let
  serverBuild = pkgs.stdenv.mkDerivation {
    name = "${name}-serverBuild";
    inherit src;
    nativeBuildInputs = with pkgs; [
      dynamo.mcman
      jre
      jre8
    ];

    buildPhase = ''
      HOME=$TMPDIR

      cd $src
      mcman build -o $out
    '';

    # If a fixed output derivation contains a store path ANYWHERE, it will fail to build
    # So we tell nix not to change it
    dontPatchShebangs = true;

    # This must be a fixed output derivation in order to access the network during a build.
    # Mcman does this to get the mod files, server jar, etc.
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = hash;
  };

  serverRuntime = pkgs.stdenv.mkDerivation {
    name = "${name}-serverRuntime";
    inherit src;

    buildInputs = with pkgs; [
      jre
      jre8
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
        ./start.sh
      EOF
      chmod +x $out/bin/start.sh
    '';

    meta.mainProgram = "start.sh";
  };
in
  pkgs.symlinkJoin
  {
    inherit name;
    paths = [serverRuntime];
    buildInputs = with pkgs; [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/start.sh \
        --prefix PATH : ${with pkgs; lib.makeBinPath [jre jre8]} \
    '';
    meta.mainProgram = "start.sh";
  }
