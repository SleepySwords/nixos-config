{pkgs, ...}:
let prometheus_config = pkgs.writeText "prometheus.yml" ''
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: node
    static_configs:
    - targets: ['localhost:9100']

  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
  '';
in {
  environment.systemPackages = [
    pkgs.prometheus
    pkgs.prometheus-node-exporter
  ];
  launchd.daemons."node_exporter" = {
    command = "${pkgs.prometheus-node-exporter}/bin/node_exporter";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/node_exporter.out.log";
      StandardErrorPath = "/tmp/node_exporter.err.log";
    };
  };
  launchd.daemons."prometheus" = {
    command = "${pkgs.prometheus}/bin/prometheus --config.file=${prometheus_config}";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/prometheus.out.log";
      StandardErrorPath = "/tmp/prometheus.err.log";
      # Should be an actual working directory 
      WorkingDirectory = "/var/lib/";
    };
  };
}
