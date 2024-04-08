{
  lib,
  pkgs,
}:
pkgs.dynamo.buildMinecraftServer {
  name = "blah";
  src = ./vanilla;
  hash = "sha256-s85fIgI7YDAMIwGa9OlmwOcxW8AnkWlZ8Up2uWJCXP0=";
}
