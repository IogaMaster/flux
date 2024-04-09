{
  lib,
  makeWrapper,
  symlinkJoin,
  stdenv,
  dynamo,
  jre,
  jre8,
}: let
  buildMinecraftServer = args @ {
    name ? "",
    src ? null,
    hash ? "",
    meta ? {},
    ...
  }: let
    serverBuild = stdenv.mkDerivation {
      name = "${args.name}-serverBuild";
      inherit (args) src;
      nativeBuildInputs = [
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
      outputHash = args.hash;
    };

    serverRuntime = stdenv.mkDerivation {
      name = "${args.name}-serverRuntime";
      inherit src;

      buildInputs = [
        jre
        jre8
      ];

      installPhase = ''
        mkdir -p $out/bin

        cat << EOF > $out/bin/start.sh
          if [ -n "\$1" ]; then
              DIRECTORY="\$1"
          else
              DIRECTORY="."
          fi
          if [ ! -d \$DIRECTORY ]; then
              mkdir -p \$DIRECTORY
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
    symlinkJoin
    {
      inherit (args) name;
      paths = [serverRuntime];
      buildInputs = [makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/start.sh \
          --prefix PATH : ${lib.makeBinPath [jre jre8]} \
      '';
      meta.mainProgram = "start.sh";
    };
in
  (buildMinecraftServer {})
  // {
    inherit buildMinecraftServer;
  }
