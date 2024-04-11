{
  lib,
  stdenvNoCC,
  steamcmd,
}: {
  name,
  appId,
  branch ? null,
  hash,
}:
stdenvNoCC.mkDerivation {
  name = "${name}-src";
  inherit appId branch;
  builder = ./builder.sh;
  buildInputs = [
    steamcmd
  ];

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
