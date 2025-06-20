{config, pkgs, ...}: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "sleepyswords.dev";
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

  security.acme = {
    acceptTerms = true;
    certs."dash.sleepyswords.dev" = {
      email = "swords@sleepyswords.dev";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = "/var/lib/secrets/cloudflare";
      webroot = null;
    };
  };

  services.nginx.enable = true;

  services.nginx.virtualHosts."dash.sleepyswords.dev" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
<<<<<<< Updated upstream
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
||||||| Stash base
	proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
	# ssl = true;
	# ssl_certificate = "/etc/grafana/grafana.crt";
	# ssl_certificate_key = "/etc/grafana/grafana.key";
	proxyWebsockets = true;
	recommendedProxySettings = true;
=======
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        # ssl = true;
        # ssl_certificate = "/etc/grafana/grafana.crt";
        # ssl_certificate_key = "/etc/grafana/grafana.key";
        proxyWebsockets = true;
        recommendedProxySettings = true;
>>>>>>> Stashed changes
    };
  };
}
