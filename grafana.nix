{ config, pkgs, lib, ... }:
{
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
      "auth.github" = {
        enabled = true;
        client_id = "Iv23li58geD43of4GoZY";
        client_secret = "$__file{${config.age.secrets.grafana-client_secret.path}}";
        auth_url = "https://github.com/login/oauth/authorize";
        token_url = "https://github.com/login/oauth/access_token";
        api_url = "https://api.github.com/user";
        scopes = "user:email,read:org";
        allow_sign_up = true;
        auto_login = false;
        allowed_organizations = [ "gluon-census" ];
        allow_assign_grafana_admin = true;
        role_attribute_path = "contains(groups[*], '@gluon-census/grafana-admin') && 'GrafanaAdmin' || contains(groups[*], '@gluon-census/grafana-editor') && 'Editor' || 'Viewer'";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "prometheus";
          #url = "http://localhost:9090";
          #url = "http://[::1]:9090";
          url = "https://gluon-census.ffrn.de/prometheus/";
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

  age.secrets.grafana-client_secret = {
    file = ./secrets/grafana-github-client-secret.age;
    mode = "440";
    owner = "grafana";
    group = "grafana";
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
