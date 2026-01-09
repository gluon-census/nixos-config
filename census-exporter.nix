{ config, pkgs, lib, ... }:
{

  systemd.services.gluon-census-exporter = {
    description = "Gluon Census Exporter";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      WorkingDirectory = "/var/lib/gluon-census-exporter";
      StateDirectory = "gluon-census-exporter";
      StateDirectoryMode = "0755";
      BindReadOnlyPaths = [
        "${pkgs.callPackage ./census-exporter-pkg.nix {}}/share/gluon-census-exporter/communities.json:/var/lib/gluon-census-exporter/communities.json"
      ];
      ExecStart = "${pkgs.callPackage ./census-exporter-pkg.nix {}}/bin/gluon-census-exporter";
      #Restart = "on-failure";
    };
  };

  systemd.timers.gluon-census-exporter = {
    description = "Run Gluon Census Exporter every 5 minutes";
    timerConfig = {
      OnCalendar = "*:0/5";
    };
    wantedBy = [ "timers.target" ];
  };

  services.prometheus.exporters.node.enabledCollectors = [
    "textfile"
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/prometheus-node-exporter-text-files 0755 node-exporter node-exporter -"
  ];

  services.prometheus.exporters.node.extraFlags = [
    "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
  ];


  systemd.services.copy-textfile-metrics = {
    after = [ "gluon-census-exporter.service" ];
    requires = [ "gluon-census-exporter.service" ];
    wantedBy = [ "gluon-census-exporter.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "copy-textfile-metrics" ''
        cp -va /var/lib/gluon-census-exporter/*.prom /var/lib/prometheus-node-exporter-text-files/
      '';
    };
  };
}
