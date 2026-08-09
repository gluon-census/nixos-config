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

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      comin,
      ...
    }@inputs:
    {
      nixosConfigurations.census01 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          }
          comin.nixosModules.comin
          ({ pkgs, config, ... }: {
            services.comin = {
              enable = true;
              remotes = [
                {
                  name = "origin";
                  url = "https://github.com/gluon-census/nixos-config.git";
                  branches.main.name = "main";
                  branches.testing.operation = "switch"; 
                }
              ];
              postDeploymentCommand = "${pkgs.writeShellScriptBin "comin-reboot-if-needed" ''
                STATUS_JSON=$(${config.services.comin.package}/bin/comin status --json)
                IS_TESTING=$(echo "$STATUS_JSON" | ${pkgs.jq}/bin/jq '.builder.generation.selected_branch_is_testing')
                if [ "$IS_TESTING" = "true" ]; then
                  echo "On a testing branch. Skipping reboot evaluation."
                  exit 0
                fi
                NEED_REBOOT=$(echo "$STATUS_JSON" | ${pkgs.jq}/bin/jq '.need_to_reboot')
                if [ "$NEED_REBOOT" = "true" ]; then
                  if ! ${pkgs.coreutils}/bin/sleep 5; then
                    echo "Warning: sleep failed, proceeding to reboot anyway" >&2
                  fi
                  ${pkgs.systemd}/bin/systemctl reboot
                fi
              ''}/bin/comin-reboot-if-needed";
            };
          })
        ];
      };
    };
}
