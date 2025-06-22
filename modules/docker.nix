{ pkgs, inputs, ... }:
{

  imports = [
    inputs.arion.nixosModules.arion
  ];

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
      "pterodactyl".settings.services = {
        "database".service = {
          image = "mariadb:10.5";
          restart = "always";
          command = "--default-authentication-plugin=mysql_native_password";
          volumes = ["/srv/pterodactyl/database:/var/lib/mysql"];
          environment = {
            MYSQL_DATABASE= "panel";
            MYSQL_USER= "pterodactyl";
            MYSQL_PASSWORD= "CHANGE_ME";
            MYSQL_ROOT_PASSWORD= "CHANGE_ME_TOO";
          };
        };
        "cache".service = {
          image = "redis:alpine";
          restart = "always";
        };
        "panel".service = {
          image = "ghcr.io/pterodactyl/panel:latest";
          restart = "always";
          ports = [ "1338:80" "1339:443" ];
          links = [ "cache" "database" ];
          volumes = [
            "/srv/pterodactyl/var/:/app/var/"
            "/srv/pterodactyl/nginx/:/etc/nginx/http.d/"
            "/srv/pterodactyl/certs/:/etc/letsencrypt/"
            "/srv/pterodactyl/logs/:/app/storage/logs"
          ];
          environment = {
            APP_URL= "http://192.168.1.119";
            APP_TIMEZONE= "Australia/Melbourne";
            APP_SERVICE_AUTHOR= "noreply@example.com";
            DB_PASSWORD = "*db-password";
            APP_ENV = "production";
            APP_ENVIRONMENT_ONLY = "false";
            CACHE_DRIVER = "redis";
            SESSION_DRIVER = "redis";
            QUEUE_DRIVER = "redis";
            REDIS_HOST = "cache";
            DB_HOST = "database";
            DB_PORT = "3306";
          };
        };
      };
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
          ports = ["1337:3000"];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    1337 1338 1339
  ];

  users.users.swords.extraGroups = [ "podman" ];
}
