{ config, pkgs, lib, ... }:
{
  #imports = [
  #  ./acme.nix
  #];

  security.acme.certs = {
    "gluon-census.ffrn.de" = {
       profile = "shortlived";
       extraDomainNames = [
         #"[2a01:4f8:160:624c:1266:6aff:fec2:c796]"
       ];
       validMinDays = 3;
       renewInterval = "3/6:00:00";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      "auth.anonymous" = {
        enabled = true;
        org_name = "Main Org.";
      };
      server = {
        protocol = "socket";
        root_url = "https://gluon-census.ffrn.de";
      };
      #rendering.callback_url = "https://grafana.ffffm.heroia.de";
      #rendering.server_url = "http://localhost:${builtins.toString config.services.grafana-image-renderer.settings.service.port}/render";
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "prometheus";
          url = "http://localhost:9090";
          type = "prometheus";
          isDefault = true;
          editable = false;
        }
      ];
    };
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
      marcusolsson-dynamictext-panel
    ];
  };

  services.nginx.enable = true;

  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ "grafana" ];

  services.nginx.virtualHosts."gluon-census.ffrn.de" = {
    default = true;
    serverAliases = [
      #"2a01:4f8:160:624c:1266:6aff:fec2:c796"
    ];
    locations."/" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      recommendedProxySettings = true;
    };
    locations."=/metrics" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      extraConfig = ''
        allow 127.0.0.0/8;
        allow ::1;
        deny  all;
      '';
    };
    forceSSL = true;
    enableACME = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443];
  networking.firewall.allowedUDPPorts = [ 443 ];

}
