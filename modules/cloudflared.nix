{ config, pkgs, inputs, ... }:
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "480f5412-3fe8-486a-b779-f46869d13081" = {
        credentialsFile = "${config.sops.secrets."cloudflared.json".path}";
        ingress = {
          "hlb.sleepyswords.dev" = "https://hlb.sleepyswords.dev";
        };
        default = "http_status:404";
      };
    };
  };
}
