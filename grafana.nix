{ config, pkgs, lib, ... }:
{
  security.acme.certs = {
    "gluon-census.freifunk.net" = {
       profile = "shortlived";
       extraDomainNames = [
         "prometheus.gluon-census.freifunk.net"
         "gluon-census.ffrn.de"
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
        root_url = "https://gluon-census.freifunk.net";
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
        use_pkce = true;
        use_refresh_token = true;
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "prometheus";
          #url = "http://localhost:9090";
          #url = "http://[::1]:9090";
          url = "https://prometheus.gluon-census.freifunk.net/";
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

  services.nginx.virtualHosts."gluon-census.freifunk.net" = {
    default = true;
    serverAliases = [
      "gluon-census.ffrn.de"
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
