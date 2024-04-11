# Contributing to flux

This document is mainly intended for people who want to contribute to flux.
As a short reminder, this is generally what you would need to do:

1. Fork and clone the repository
2. Either stay on the `main` branch, or create a new branch for your feature `[feat|fix|...]/<name>`.
   If you are working on multiple PRs at the same time, you should create new branches.
3. Run `nix develop`. You will be put into a shell with a pre-commit-hook that automatically
   checks and lints your changes before you push.
4. Read the chapter below and implement your changes
5. Once finished, create a commit, push your changes and submit a PR.

## Requirements for submitted changes

If you want to submit a change, please make sure you have checked the following things:

- All checks must pass. You can run them with `nix flake check`, which will also check formatting.
- This repository follows the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) style.
  So each commit in your PR should contain only one logical change and the commit message
  should reflect that accordingly.

  Example: If your PR changes two builders, you should also have two commits:
  - `feat(builders/mkMinecraftServer): fix longstanding issue`
  - `feat(helpers/fetchSteam): speed up`

  Changes to builders should be scoped like `feat(builders/<builder_name>)`,
  same for `helpers/<helper_name>` and `modules/<module_name>`. If a change
  doesn't fit any of these scopes, then just don't add a scope.
