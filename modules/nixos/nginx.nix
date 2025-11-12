{config, pkgs, ...}: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    defaults = {
      email = "swords@sleepyswords.dev";
    };
    acceptTerms = true;
    certs."hlb.sleepyswords.dev" = {
      email = "swords@sleepyswords.dev";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = "/run/secrets/cloudflare.env";
      webroot = null;
      extraDomainNames = [ "*.hlb.sleepyswords.dev" ];
    };
  };

  services.nginx.enable = true;

  networking.hosts = {
    "192.168.1.101" = ["hlb.sleepyswords.dev"];
  };

  services.nginx.virtualHosts."hlb.sleepyswords.dev" = {
    addSSL = true;
    enableACME = true;
  };
}
