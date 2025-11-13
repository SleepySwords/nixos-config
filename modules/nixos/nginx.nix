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
    locations."/eventhub/api/" = {
        proxyPass = "http://192.168.1.118:8080/api/";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
    locations."/eventhub/images/" = {
        proxyPass = "http://192.168.1.118:9000/images/";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
    locations."/eventhub" = {
        proxyPass = "http://192.168.1.118:3000";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
  };
}
