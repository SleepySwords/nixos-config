{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.prometheus
    pkgs.prometheus-node-exporter
  ];
  launchd.daemons."node_exporter" = {
    command = "${pkgs.prometheus-node-exporter}/bin/node_exporter";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
