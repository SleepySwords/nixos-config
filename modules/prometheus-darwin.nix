{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.prometheus
  ];
}
