#!/bin/bash

URL="${NIXOS_CONFIG:-https://github.com/SleepySwords/nixos-config}"

if cd ~/nixos-config;
    then git pull;
    else git clone $URL ~/nixos-config;
fi;

sudo nixos-rebuild switch --flake ~/nixos-config
