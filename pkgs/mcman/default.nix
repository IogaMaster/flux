{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  bzip2,
  zstd,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "mcman";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "deniz-blue";
    repo = "mcman";
    rev = version;
    hash = "sha256-/WIm2MFj2++QVCATDkYz2h4Jm+0RzxzVFIYrZubEgIQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "mcapi-0.2.0" = "sha256-wHXA+4DQVQpfSCfJLFuc9kUSwyqo6T4o0PypYdhpp5s=";
      "pathdiff-0.2.1" = "sha256-+X1afTOLIVk1AOopQwnjdobKw6P8BXEXkdZOieHW5Os=";
      "rpackwiz-0.1.0" = "sha256-pOotNPIZS/BXiJWZVECXzP1lkb/o9J1tu6G2OqyEnI8=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    zstd
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = {
    description = "Powerful Minecraft Server Manager CLI. Easily install jars (server, plugins & mods) and write config files. Docker and git support included";
    homepage = "https://github.com/deniz-blue/mcman";
    changelog = "https://github.com/deniz-blue/mcman/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ iogamaster ];
    mainProgram = "mcman";
  };
}
