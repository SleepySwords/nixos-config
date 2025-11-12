{ config, pkgs, inputs, ... }:
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "c0978d36-a466-4eea-a8bd-09e5615a19a2" = {
        credentialsFile = "${config.sops.secrets."cloudflared.json".path}";
        ingress = {
          "hlb.sleepyswords.dev" = "https://hlb.sleepyswords.dev";
        };
        default = "http_status:404";
      };
    };
  };
}
