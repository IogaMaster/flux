{
  lib,
  buildFHSEnv,
  symlinkJoin,
  makeWrapper,
  bash,
  stdenv,
  dynamo,
  jre,
  jre8,
}: {
  name ? "",
  src ? null,
  nativeBuildInputs ? [],
  buildInputs ? [],
  hash,
  meta ? {},
  ...
}: let
  server = stdenv.mkDerivation {
    name = "server";
    inherit src;

    nativeBuildInputs =
      [
        dynamo.mcman
      ]
      ++ nativeBuildInputs;

    buildPhase = ''
      HOME=$TMPDIR

      cd $src
      mcman build -o $out
    '';

    fixupPhase = ''
      # mainProgram requires that the start script is in $out/bin
      # So we prepend a change of dir so start.sh can find the server files
      mkdir -p $out/bin && mv $out/start.sh $out/bin/start.sh
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
in
  buildFHSEnv {
    inherit name;
    targetPkgs = pkgs: [
      (symlinkJoin
        {
          name = "${name}-dynamo";
          paths = [server];
          buildInputs = [makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/start.sh \
              --prefix PATH : ${lib.makeBinPath [jre jre8]} \
          '';
          meta.mainProgram = "start.sh";
        })
    ];

    extraInstallCommands = ''
      cp -r ${server} $out
      echo "$(cat $out/bin/start.sh)" > $out/bin/start.sh
    '';

    runScript = ''
      start.sh
    '';
  }
