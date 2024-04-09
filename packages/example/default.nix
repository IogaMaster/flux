{
  lib,
  pkgs,
}:
lib.dynamo.mkMinecraftServer pkgs {
  name = "example-vanilla-server";
  src = ./vanilla;
  hash = "sha256-s85fIgI7YDAMIwGa9OlmwOcxW8AnkWlZ8Up2uWJCXP0=";
}
