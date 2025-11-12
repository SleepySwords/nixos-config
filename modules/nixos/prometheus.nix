{ config, pkgs, ... }:
{
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
}
