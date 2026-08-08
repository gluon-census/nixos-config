{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    agenix.url = "github:ryantm/agenix";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, comin, ... }@inputs: {
    nixosConfigurations.census01 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];

          /*system.autoUpgrade = {
            enable = true;
            upgrade = false;
            dates = "hourly";
            randomizedDelaySec = "15min";
            persistent = false;
            flags = [
              "--print-build-logs"
              "--update-input" "nixpkgs"
              "--commit-lock-file"
              "--recreate-lock-file"
            ];
            allowReboot = true;
          };*/
        }
        comin.nixosModules.comin
        ({
          services.comin = {
            enable = true;
            remotes = [{
              name = "origin";
              url = "https://github.com/gluon-census/nixos-config.git";
              branches.main.name = "main";
            }];
          };
        })
      ];
    };
  };
}
