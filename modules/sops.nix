{ sops, ... }:
{
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    sops.secrets."test" = {
    sopsFile = ./secrets/homelab.yaml;
  };
}
