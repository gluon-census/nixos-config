{ config, pkgs, lib, ... }:
{

  services.prometheus = {
    enable = true;
    listenAddress = "[::1]";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
      scrape_timeout = "12s";
    };
    extraFlags = [
      "--storage.tsdb.retention.size=10GB"
    ];
  };

  services.prometheus.webExternalUrl = "https://prometheus.gluon-census.freifunk.net/";
  services.nginx.virtualHosts."prometheus.gluon-census.freifunk.net" = {
    locations."/" = {
      proxyPass = "http://${config.services.prometheus.listenAddress}:9090";
      recommendedProxySettings = true;
    };
    useACMEHost = "gluon-census.freifunk.net";
    forceSSL = true;
    extraConfig = ''
      listen [::]:444 ssl proxy_protocol;
      listen 0.0.0.0:444 ssl proxy_protocol;
    '';
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{
        targets = [
          "localhost:9100"
        ];
      }];
    }
  ];

  services.prometheus.exporters.node = {
    enable = true;
  };

}
