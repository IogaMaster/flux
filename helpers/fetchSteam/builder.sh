#!/bin/bash
# shellcheck source=/dev/null
if [ -e .attrs.sh ]; then source .attrs.sh; fi
source "${stdenv:?}/setup"

export HOME
HOME=$(mktemp -d)

mkdir -p $out
mkdir -p downloadDir
cd downloadDir
steamcmd +force_install_dir $(pwd) +login anonymous +app_update $appId validate +quit
cp -r . $out
