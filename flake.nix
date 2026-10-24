{
  description = "flake-parts configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{
    flake-parts,
    home-manager,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager.flakeModules.home-manager
      ];
      flake = {
        homeModules.homeManager = { ... }: {
          programs.home-manager.enable = true;
          home.sessionVariables = {
            PATH = "$HOME/.nix-profile/bin:$PATH";
          };
        };

        homeModules.cli = { pkgs, ... }: {
          programs.vim = { 
            enable = true;
            defaultEditor = true;
          };
          programs.ripgrep.enable = true;
          programs.fd.enable = true;
          programs.jujutsu = {
            enable = true;
            settings = {
              user = {
                name = "Ben Simms";
                email = "ben@bensimms.moe";
              };
            };
          };
          programs.git = {
            enable = true;
            settings = {
              user = {
                name = "Ben Simms";
                email = "ben@bensimms.moe";
              };
            };
          };

          home.packages = with pkgs; [
            just
            nix
          ];
        };

        homeModules.nushell = { ... }: {
          programs.nushell = {
            enable = true;
            loadSessionVariables = true;
          };
          programs.starship = {
            enable = true;
            enableNushellIntegration = true;
          };
          home.shell.enableNushellIntegration = true;
          home.shell.enableBashIntegration = true;
        };

        homeModules.bashrc = { config, ... }: {
          home.activation.writeBashRc = ''
            cp ${./profile} $HOME/.profile && chmod 600 $HOME/.profile
            cp ${./bashrc} $HOME/.bashrc && chmod 600 $HOME/.bashrc
          '';
        };

        # Concrete Home Manager configuration.
        homeConfigurations.defaultuser = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          modules = [
            inputs.self.homeModules.homeManager
            inputs.self.homeModules.nushell
            inputs.self.homeModules.cli
            inputs.self.homeModules.bashrc
            ./mkAbsoluteSymlink.nix
            {
              home.username = "defaultuser";
              home.homeDirectory = "/home/defaultuser";
              home.stateVersion = "26.05";
            }
          ];
        };
      };
    };
}

