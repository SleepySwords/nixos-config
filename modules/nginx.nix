{config, pkgs, ...}: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    certs."homelab.sleepyswords.dev" = {
      email = "swords@sleepyswords.dev";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = "/var/lib/secrets/cloudflare";
      webroot = null;
    };
  };

  services.nginx.enable = true;

  services.nginx.virtualHosts."homelab.sleepyswords.dev" = {
    addSSL = true;
    enableACME = true;
  }
