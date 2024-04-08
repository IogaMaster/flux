{
  lib,
  makeWrapper,
  symlinkJoin,
  stdenv,
  dynamo,
  jre,
  jre8,
}: {
  name ? "",
  src ? null,
  nativeBuildInputs ? [],
  buildInputs ? [],
  extraSetupCommands ? "",
  hash,
  meta ? {},
  ...
}: let
  serverBuild = stdenv.mkDerivation {
    name = "${name}-serverBuild";
    inherit src;
    nativeBuildInputs =
      [
        dynamo.mcman
        jre
        jre8
      ]
      ++ nativeBuildInputs;

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

  serverRuntime = stdenv.mkDerivation {
    name = "${name}-serverRuntime";
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
        DIRECTORY="\$XDG_DATA_HOME/dynamo/servers/minecraft/${name}"
        if [ ! -d \$DIRECTORY ]; then
            mkdir -p \$DIRECTORY
            cp -r ${serverBuild}/. \$DIRECTORY
            cd \$DIRECTORY
            ${extraSetupCommands}
        fi
        cd \$DIRECTORY
        ./start.sh
      EOF
      chmod +x $out/bin/start.sh
    '';

    meta.mainProgram = "start.sh";
  };
in
  symlinkJoin
  {
    inherit name;
    paths = [serverRuntime];
    buildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/start.sh \
        --prefix PATH : ${lib.makeBinPath [jre jre8]} \
    '';
    meta.mainProgram = "start.sh";
  }
