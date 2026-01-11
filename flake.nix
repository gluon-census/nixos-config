{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix, ... }@inputs: {
    nixosConfigurations.gluon-census = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];

          system.autoUpgrade = {
            enable = true;
            flake = inputs.self.outPath;
            flags = [
              "--print-build-logs"
            ];
            dates = "02:00";
            randomizedDelaySec = "45min";
          };
        }
      ];
    };
  };
}
