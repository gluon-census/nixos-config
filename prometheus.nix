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
      #extraConfig = ''
      #  allow 127.0.0.0/8;
      #  allow ::1;
      #  deny  all;
      #'';
    };
    useACMEHost = "gluon-census.freifunk.net";
    forceSSL = true;
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
