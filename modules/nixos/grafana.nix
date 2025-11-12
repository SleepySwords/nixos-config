{config, pkgs, ...}: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "hlb.sleepyswords.dev";
        root_url = "https://hlb.sleepyswords.dev/dash/";
        serve_from_sub_path = true;
      };
    };
  };

  services.nginx.virtualHosts."hlb.sleepyswords.dev" = {
    locations."/dash" = {
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
  };
}
