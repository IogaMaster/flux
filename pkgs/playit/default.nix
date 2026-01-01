{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "playit";
  version = "0.16.5";

  src = fetchFromGitHub {
    owner = "playit-cloud";
    repo = "playit-agent";
    rev = "v${version}";
    hash = "sha256-0N1NpFl8ekqEtsfdr6Zv8a2xmwrl5e6Zn8ar8ajJZmo=";
  };

  cargoHash = "sha256-zS/ipFGltQJZKlhK92EWEYvxUk+yK1q4yoAqdQocMpE=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  doCheck = false;

  meta = with lib; {
    description = "The playit program";
    homepage = "https://github.com/playit-cloud/playit-agent";
    license = licenses.bsd2;
    maintainers = with maintainers; [];
    mainProgram = "playit-cli";
  };
}
