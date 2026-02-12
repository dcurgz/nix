{
  description = "NixOS configuration as a flake";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    dankMaterialShell.inputs.dgop.follows = "dgop";
    dankMaterialShell.inputs.nixpkgs.follows = "nixpkgs";
    dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:dcurgz/deploy-rs/dcurgz/add-skip-offline";
    dgop.inputs.nixpkgs.follows = "nixpkgs";
    dgop.url = "github:AvengeMedia/dgop";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko/latest";
    flake-compat.flake = false;
    flake-compat.url = "github:NixOS/flake-compat";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    isd.url = "github:kainctl/isd"; # systemd tui
    maccel.url = "github:Gnarus-G/maccel"; # mouse acceleration kernel driver
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    naersk.url = "github:nix-community/naersk";
    neoforge-1-21-1.inputs.nixpkgs.follows = "nixpkgs";
    neoforge-1-21-1.url = "path:./pkgs/neoforge-1-21-1";
    nfsm.inputs.nixpkgs.follows = "nixpkgs";
    nfsm.url = "github:gvolpe/nfsm";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:sodiboo/niri-flake";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
    nix-rosetta-builder.inputs.nixpkgs.follows = "nixpkgs";
    nix-time.url = "path:./pkgs/flockenzeit";
    nixgl.url = "github:nix-community/nixGL";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nurpkgs.inputs.nixpkgs.follows = "nixpkgs";
    nurpkgs.url = "github:nix-community/NUR"; # Nix user repository
    weirdfish-server.inputs.nixpkgs.follows = "nixpkgs";
    weirdfish-server.url = "path:./pkgs/weirdfish-server";
  };

  outputs =
    {
      self,
      agenix,
      dankMaterialShell,
      deploy-rs,
      dgop,
      disko,
      flake-compat,
      home-manager,
      isd,
      maccel,
      microvm,
      naersk,
      neoforge-1-21-1,
      nfsm,
      niri,
      nix-darwin,
      nix-homebrew,
      nix-minecraft,
      nix-rosetta-builder,
      nix-time,
      nixgl,
      nixpkgs,
      nurpkgs,
      weirdfish-server,
    }@inputs:

    let
      globals = {
        FLAKE_ROOT = ./.;

        COMMON_PRESETS = ./presets/common;
        COMMON_MODULES = ./modules/common;
        HM_PRESETS     = ./presets/home-manager;
        HM_MODULES     = ./modules/home-manager;
        NIXOS_PRESETS  = ./presets/nixos;
        NIXOS_MODULES  = ./modules/nixos;
      };
    in
    {
      nixosConfigurations = {
        hyperberry =
          let
            system = "x86_64-linux";
          in
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                # Pass arguments to all modules.
                inherit inputs globals;
              };
              modules = [
                # Apply overlays to nixpkgs
                {
                  nixpkgs.config.allowUnfree = true;
                  nixpkgs.config.allowUnfreePredicate = _: true;
                  nixpkgs.overlays = [
                    (final: prev: import ./overlays.nix { inherit inputs final prev; })
                    nixgl.overlay
                    nurpkgs.overlays.default
                  ];
                }
                ./modules/common
                ./modules/nixos
                # git-crypt protected variables
                ./secrets/berry.enc.nix
                # Main configuration files
                ./systems/hyperberry/hardware.nix
                ./systems/hyperberry
                ./presets/common/ssh.nix
                ./presets/common/git.nix
                ./presets/nixos/misc/nix-daemon.nix
                ./presets/nixos/security/sudo
                ./presets/nixos/security/groups
                ./presets/nixos/packages/core
                ./presets/nixos/packages/encryption
                ./presets/nixos/packages/python
                ./presets/nixos/vms/immich
                ./presets/nixos/vms/minecraft-wg-0
                ./presets/nixos/vms/minecraft-slime
                ./presets/nixos/vms/minecraft-slime_staging
                ./presets/nixos/vms/teamspeak
                ./presets/nixos/vms/jellyfin
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.dcurgz = import ./users/dcurgz/hyperberry;
                  home-manager.sharedModules = [
                    ./modules/home-manager/common
                    ./modules/home-manager/nixos
                    # 3rd party modules
                    niri.homeModules.niri
                    dankMaterialShell.homeModules.dankMaterialShell.default
                    dankMaterialShell.homeModules.dankMaterialShell.niri
                  ];
                  home-manager.extraSpecialArgs = {
                    # Pass arguments to home
                    inherit globals;
                  };
                  home-manager.backupFileExtension = "bak";
                }
                # 3rd party modules
                home-manager.nixosModules.home-manager
                microvm.nixosModules.host
                agenix.nixosModules.default
              ];
            };

        blueberry = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            # Pass arguments to all modules.
            inherit inputs globals;
          };
          modules = [
            # Apply overlays to nixpkgs
            {
              nixpkgs.overlays = [
                (final: prev: import ./overlays.nix { inherit inputs final prev; })
                nurpkgs.overlays.default
              ];
	      nixpkgs.config.allowUnfree = true;
            }
            ./modules/common
            ./modules/nixos
            # git-crypt protected variables
            ./secrets/berry.enc.nix
            # Main configuration files
            ./systems/blueberry/hardware.nix
            ./systems/blueberry/disk-config.nix
            ./systems/blueberry
            ./presets/common/ssh.nix
            ./presets/common/git.nix
            ./presets/nixos/misc/nix-daemon.nix
            ./presets/nixos/security/sudo
            ./presets/nixos/security/groups
            ./presets/nixos/packages/core
            ./presets/nixos/packages/encryption
            ./presets/nixos/packages/python
            ./presets/nixos/drivers/nvidia
            ./presets/nixos/services/avahi
            # Desktop environment
            ./presets/nixos/drivers/maccel
            ./presets/nixos/desktop/xdg
            ./presets/nixos/desktop/audio
            ./presets/nixos/desktop/gpg
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
		./modules/home-manager/common
		./modules/home-manager/nixos
                # 3rd party modules
                niri.homeModules.niri
                dankMaterialShell.homeModules.dankMaterialShell.default
                dankMaterialShell.homeModules.dankMaterialShell.niri
              ];
              home-manager.users.dcurgz = import ./users/dcurgz/blueberry;
              home-manager.extraSpecialArgs = {
                # Pass arguments to home
		inherit inputs globals;
              };
              home-manager.backupFileExtension = "bak";
            }
            # 3rd party modules
            home-manager.nixosModules.home-manager
            microvm.nixosModules.host
            agenix.nixosModules.default
            maccel.nixosModules.default
            disko.nixosModules.disko
          ];
        };

        piberry = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self nixpkgs inputs globals;
          };
          modules = [
            {
              nixpkgs.overlays = [
                (final: prev: import ./overlays.nix { inherit inputs final prev; })
              ];
            }
            ./modules/common
            ./modules/nixos
            # git-crypt protected variables
            ./secrets/berry.enc.nix
            ./systems/piberry
            ./presets/nixos/misc/nix-daemon.nix
            ./presets/nixos/packages/core
            ./presets/nixos/security/groups
            ./presets/nixos/services/home-assistant
            ./presets/nixos/services/matter
            # 3rd party modules
            microvm.nixosModules.host
            agenix.nixosModules.default
          ];
        };

        tauberry = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self nixpkgs inputs globals;
          };
          modules = [
            {
              nixpkgs.overlays = [
                (final: prev: import ./overlays.nix { inherit inputs final prev; })
              ];
            }
            ./modules/common
            ./modules/nixos
            # git-crypt protected variables
            ./secrets/berry.enc.nix
            ./systems/tauberry
            ./presets/nixos/misc/rpi-disable-kernel-modules.nix
            ./presets/nixos/misc/nix-daemon.nix
            ./presets/nixos/packages/core
            # 3rd party modules
            microvm.nixosModules.host
            agenix.nixosModules.default
          ];
        };

        fooberry = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            # Pass arguments to all modules.
            inherit inputs globals;
          };
          modules = [
            # Apply overlays to nixpkgs
            {
              nixpkgs.overlays = [
                (final: prev: import ./overlays.nix { inherit inputs final prev; })
                nurpkgs.overlays.default
              ];
	      nixpkgs.config.allowUnfree = true;
            }
            ./modules/common
            ./modules/nixos
            # git-crypt protected variables
            ./secrets/berry.enc.nix
            # Main configuration files
            ./systems/fooberry/hardware.nix
            ./systems/fooberry/disk-config.nix
            ./systems/fooberry
            ./presets/common/ssh.nix
            ./presets/nixos/misc/nix-daemon.nix
            ./presets/nixos/security/sudo
            ./presets/nixos/security/groups
            ./presets/nixos/packages/core
            ./presets/nixos/services/avahi
            # 3rd party modules
            microvm.nixosModules.host
            agenix.nixosModules.default
            disko.nixosModules.disko
          ];
        };

        weirdfish-cax11-4gb = nixpkgs.lib.nixosSystem rec {
          system = "aarch64-linux";
          specialArgs = {
            # Pass arguments to all modules.
            inherit self inputs globals;
          };
          modules = [
            # Apply overlays to nixpkgs
            {
              nixpkgs.overlays = [
                (final: prev: import ./overlays.nix { inherit inputs final prev; })
                nixgl.overlay
                nurpkgs.overlays.default
              ];
            }
            ./modules/common
            ./modules/nixos
            ./modules/www
            # git-crypt protected variables
            ./secrets/berry.enc.nix
            # Main configuration files
            ./systems/weirdfi.sh-cax11-4gb/hardware-configuration.nix
            ./systems/weirdfi.sh-cax11-4gb/disk-config.nix
            ./systems/weirdfi.sh-cax11-4gb
            ./presets/common/ports.nix
            ./presets/nixos/misc/nix-daemon.nix
            ./presets/nixos/security/sudo
            ./presets/nixos/security/groups
            ./presets/nixos/packages/core
            ./presets/nixos/packages/encryption
            ./presets/nixos/packages/python
            # Websites
            weirdfish-server.nixosModules.${system}.default
            ./presets/www/dcurgz.me
            ./presets/www/weirdfi.sh
            ./presets/nixos/websites/dcurgz.me
            ./presets/nixos/websites/weirdfi.sh
            # 3rd party modules
            microvm.nixosModules.host
            agenix.nixosModules.default
            # declarative partition management
            disko.nixosModules.disko
          ];
        };
      };

      darwinConfigurations."airberry" = nix-darwin.lib.darwinSystem {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          overlays = [
            (final: prev: import ./overlays.nix { inherit inputs final prev; })
            nixgl.overlay
            nurpkgs.overlays.default
          ];
          config.allowUnfree = true;
        };
        specialArgs = {
          inherit self nix-homebrew inputs globals;
        };
        modules = [
          ./modules/common
          #./modules/darwin
          ./secrets/berry.enc.nix
          ./presets/common/ssh.nix
          ./presets/darwin/misc/nix-daemon.nix
          ./systems/airberry
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dylan = import ./users/dcurgz/airberry;
            home-manager.sharedModules = [
              ./modules/home-manager/common
              ./modules/home-manager/darwin
            ];
            home-manager.extraSpecialArgs = {
              # Pass arguments to home
              inherit globals;
            };
            home-manager.backupFileExtension = "bak";
          }
          {
            nix.linux-builder.enable = true;
          }
          # 3rd party modules
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          agenix.darwinModules.default
        ];
      };

      darwinConfigurations."miniberry" = nix-darwin.lib.darwinSystem {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          overlays = [
            (final: prev: import ./overlays.nix { inherit inputs final prev; })
            nixgl.overlay
            nurpkgs.overlays.default
          ];
          config.allowUnfree = true;
        };
        specialArgs = {
          inherit self nix-homebrew globals;
        };
        modules = [
          ./modules/common
          ./systems/miniberry
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dcurgz = import ./users/dcurgz/miniberry;
            home-manager.extraSpecialArgs = {
              # Pass arguments to home
              inherit globals;
            };
          }
          # 3rd party modules
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
        ];
      };

      packages =
        let
          systems = [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ];
        in
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                (final: prev: import ./overlays.nix { inherit inputs final prev; })
                nixgl.overlay
                nurpkgs.overlays.default
              ];
            };
          in
          {
            # Custom packages
            #keylight = pkgs.by.keylight;
            weirdfish-server = pkgs.by.weirdfish-server;
            neoforge-1-21-1 = pkgs.by.neoforge-1-21-1;
          }
        );

      # Deploy-rs configuration
      deploy.nodes = {
        blueberry = {
          hostname = "blueberry";
          sshUser = "dcurgz";
          remoteBuild = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.blueberry;
          };
        };

        hyperberry = {
          hostname = "hyperberry";
          sshUser = "dcurgz";
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hyperberry;
          };
        };

        piberry = {
          hostname = "piberry";
          sshUser = "piberry";
          remoteBuild = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.piberry;
          };
        };

        tauberry = {
          hostname = "tauberry";
          sshUser = "tauberry";
          remoteBuild = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.tauberry;
          };
        };

        airberry = {
          hostname = "airberry";
          sshUser = "dylan";
          remoteBuild = false;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.airberry;
          };
        };

        miniberry = {
          hostname = "miniberry";
          sshUser = "dcurgz";
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.miniberry;
          };
        };

        fooberry = {
          hostname = "fooberry";
          sshUser = "dcurgz";
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.fooberry;
          };
        };

        weirdfish-cax11-4gb = {
          hostname = "weirdfi.sh";
          sshUser = "root";
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.weirdfish-cax11-4gb;
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
