{ pkgs, inputs, ... }:
{

  imports = [
    inputs.arion.nixosModules.arion
  ];

  environment.systemPackages = [
    # pkgs.arion
    pkgs.docker-client
  ];

  virtualisation.docker.enable = true;
  # virtualisation.podman.enable = true;
  # virtualisation.podman.dockerSocket.enable = true;
  # virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  virtualisation.arion = {
    backend = "docker";
    projects = {
      "pterodactyl".settings.services = {
        "database".service = {
          image = "mariadb:10.5";
          restart = "always";
          command = "--default-authentication-plugin=mysql_native_password";
          volumes = ["/srv/pterodactyl/database:/var/lib/mysql"];
          ports = ["3306:3306"];
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
          # links = [ "cache" "database" ];
          volumes = [
            "/srv/pterodactyl/var/:/app/var/"
            "/srv/pterodactyl/nginx/:/etc/nginx/http.d/"
            "/srv/pterodactyl/certs/:/etc/letsencrypt/"
            "/srv/pterodactyl/logs/:/app/storage/logs"
          ];
          environment = {
            APP_URL= "https://homelab.sleepyswords.dev/";
            APP_TIMEZONE= "Australia/Melbourne";
            APP_SERVICE_AUTHOR= "noreply@example.com";
            DB_PASSWORD = "CHANGE_ME";
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
        "wings".service = {
          image = "ghcr.io/pterodactyl/wings:latest";
          restart = "always";
          ports = ["8080:8080" "2022:2022"];
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "/var/lib/docker/containers/:/var/lib/docker/containers/"
            "/etc/pterodactyl/:/etc/pterodactyl/"
            "/var/lib/pterodactyl/:/var/lib/pterodactyl/"
            "/var/log/pterodactyl/:/var/log/pterodactyl/"
            "/tmp/pterodactyl/:/tmp/pterodactyl/"
            "/etc/ssl/certs:/etc/ssl/certs:ro"
          ];
          tty = true;
          environment = {
            TZ = "Australia/Melbourne";
            WINGS_UID = 988;
            WINGS_GID = 988;
            WINGS_USERNAME = "pterodactyl";
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

  environment.etc."pterodactyl/config.yml" = {
    text = ''
      debug: false
      uuid: a2bc0834-5516-4134-b61e-7a2ab9b55195
      token_id: BAJsTBvxyhBV8Jts
      token: w35ghwknymNB2dbcEtUHrKxpZxTCCN4tdGTXE8nqBN3VrpEXwvJNd5wmiKuplPmz
      api:
        host: 0.0.0.0
        port: 8080
        ssl:
          enabled: false
          cert: /etc/letsencrypt/live/192.168.1.119/fullchain.pem
          key: /etc/letsencrypt/live/192.168.1.119/privkey.pem
        upload_limit: 100
      system:
        data: /var/lib/pterodactyl/volumes
        sftp:
          bind_port: 2022
      allowed_mounts: []
      remote: 'https://homelab.sleepyswords.dev'
    '';

    group = "arion";
    user = "swords";
  };

  services.nginx.virtualHosts."homelab.sleepyswords.dev" = {
    locations."/wikijs" = {
        proxyPass = "http://localhost:1337";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
    locations."/" = {
        proxyPass = "http://localhost:1338";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    1339 3306 8080 2022
  ];

  users.users.swords.extraGroups = [ "podman" ];
}
