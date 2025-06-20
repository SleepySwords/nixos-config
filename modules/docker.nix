{ pkgs, ... }:
{

  environment.systemPackages = [
    pkgs.arion

    pkgs.docker-client
  ];

  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  users.users.swords.extraGroups = [ "podman" ];
}
