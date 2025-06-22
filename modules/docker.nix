{ pkgs, ... }:
{

  environment.systemPackages = [
    pkgs.docker-client
  ];

  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  virtualisation.arion = {
    backend = "podman-socket";
    projects = {
      "wikijs".settings.services = {
        "db".service = {
          image = "postgres:15-alpine";
          restart = "unless-stopped";
          environment = { 
            POSTGRES_DB= "wiki";
            POSTGRES_PASSWORD= "wikijsrocks";
            POSTGRES_USER= "wikijs";
          };
        };
        "wiki".service = {
          image = "ghcr.io/requarks/wiki:2";
          depends_on = ["db"];
          restart = "unless-stopped";
          environment = { 
            DB_TYPE= "postgres";
            DB_HOST= "db";
            DB_PORT= "5432";
            DB_USER= "wikijs";
            DB_PASS= "wikijsrocks";
            DB_NAME= "wiki";
          };
          ports = ["1337:3000"]
        }
      };
    };
  };

  users.users.swords.extraGroups = [ "podman" ];
}
