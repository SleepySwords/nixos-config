{ pkgs, ... }:
let
  deploy-from-git = (pkgs.writeShellScriptBin "deploy-from-git" ''
#!/bin/bash

URL="''${NIXOS_CONFIG:-https://github.com/SleepySwords/nixos-config}"

if cd ~/nixos-config;
    then git fetch;
         git reset --hard origin/master;
    else git clone $URL ~/nixos-config;
fi;

sudo ${"${toString pkgs.nixos-rebuild}/bin/nixos-rebuild"} switch --flake ~/nixos-config --show-trace
    '');
in {
  users.users.deploy = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHz29F59kPjXDtuA12h3U2qUL/aun7yMellK4WR4h7Ye ibby"
    ];
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  security.sudo.extraRules = [
    {
      users = ["deploy"];
      commands = [ { command = "${toString pkgs.nixos-rebuild}/bin/nixos-rebuild"; options = [ "SETENV" "NOPASSWD" ]; } ];
    }
  ];

  environment.systemPackages = with pkgs; [
    deploy-from-git
  ];
}
