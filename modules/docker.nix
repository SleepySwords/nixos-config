{ ... }:
{
  virtualisation.docker.enable = true;

  users.users.swords.extraGroups = [ "docker" ];

}
