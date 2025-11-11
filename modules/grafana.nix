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

  services.prometheus = {
    port = 9001;
    enable = true;
    exporters = {
        node = {
          port = 9002;
          enabledCollectors = [ "systemd" ];
          enable = true;
        };
    };

    scrapeConfigs = [
      {
        job_name = "chrysalis";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx.enable = true;

  services.nginx.virtualHosts."hlb.sleepyswords.dev" = {
    locations."/dash" = {
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
  };
}
