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
    retentionTime = "30d";

    #webExternalUrl = "https://gluon-census.ffrn.de/prometheus/";
  };


  services.prometheus.webExternalUrl = "https://gluon-census.ffrn.de/prometheus/";
  services.nginx.virtualHosts."gluon-census.ffrn.de" = {
    locations."/prometheus/" = {
      proxyPass = "http://${config.services.prometheus.listenAddress}:9090";
      recommendedProxySettings = true;
      #extraConfig = ''
      #  allow 127.0.0.0/8;
      #  allow ::1;
      #  deny  all;
      #'';
    };
  };

}
