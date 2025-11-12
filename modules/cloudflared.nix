{ pkgs, inputs, ... }:
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "8e58a865-17ad-487e-b75e-bb1fce7e87eb" = {
        credentialsFile = "${config.sops.secrets.cloudflared.path}";
      };
    };
  };
}
