{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.defaultSopsFile = ../secrets/homelab.yaml;
  sops.secrets.hello = {
    format = "yaml";
  };

  sops.secrets."cloudflare.env" = {
    sopsFile = ../secrets/cloudflare.env;
    path = "/run/secrets/cloudflare.env";
    format = "dotenv";
    key = "";
  };
}
