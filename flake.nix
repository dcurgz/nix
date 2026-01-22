{
  description = "NixOS configuration as a flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Static packages with better cache support
    nixpkgs-static.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Nix user repository
    nurpkgs.url = "github:nix-community/NUR";
    nurpkgs.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # build aarch64-linux and x86_64-linux on Darwin
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    nfsm = {
      url = "github:gvolpe/nfsm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = { # CPU and memory monitoring
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankMaterialShell = { # Dank Material Shell for DE
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    };

    # Mouse acceleration
    maccel.url = "github:Gnarus-G/maccel";

    # isd: systemd tui
    isd.url = "github:kainctl/isd";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    naersk.url = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";

    weirdfish-server.url = "path:./pkgs/dcurgz/weirdfish-server";
    weirdfish-server.inputs.nixpkgs.follows = "nixpkgs";

    nix-time.url = "path:./pkgs/3rd-party/Flockenzeit";
  };

  outputs =
    {
      self,
      nixgl,
      nix-darwin,
      nix-homebrew,
      nix-rosetta-builder,
      home-manager,
      maccel,
      niri,
      nfsm,
      dgop,
      dankMaterialShell,
      nixpkgs,
      nixpkgs-static,
      nurpkgs,
      microvm,
      isd,
      nix-minecraft,
      deploy-rs,
      agenix,
      disko,
      naersk,
      weirdfish-server,
      nix-time,
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
                ./presets/nixos/misc/nix-daemon.nix
                ./presets/nixos/security/sudo
                ./presets/nixos/packages/core
                ./presets/nixos/packages/encryption
                ./presets/nixos/packages/python
                ./presets/nixos/containers/dropbox
                ./presets/nixos/containers/open-webui
                ./presets/nixos/vms/immich
                ./presets/nixos/vms/minecraft-wg-0
                ./presets/nixos/vms/minecraft-wg-1
                ./presets/nixos/vms/teamspeak
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.dcurgz = import ./users/dcurgz/hyperberry;
                  home-manager.sharedModules = [
                    ./modules/common
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
            ./systems/blueberry
            ./presets/nixos/misc/nix-daemon.nix
            ./presets/nixos/security/sudo
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
            # Enable VPN
            # Currently DCs every 2 minutes..try different endpoint?
            #./presets/nixos/networking/vpns/proton.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
		./modules/common
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
          ];
        };

        piberry = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self nixpkgs;
            inputs = {
              inherit self nixpkgs;
            };
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
            ./presets/nixos/containers/home-assistant
            # 3rd party modules
            microvm.nixosModules.host
            agenix.nixosModules.default
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
            # git-crypt protected variables
            ./secrets/berry.enc.nix
            # Main configuration files
            ./systems/weirdfi.sh-cax11-4gb/hardware-configuration.nix
            ./systems/weirdfi.sh-cax11-4gb/disk-config.nix
            ./systems/weirdfi.sh-cax11-4gb
            ./presets/common/ports.nix
            ./presets/nixos/misc/nix-daemon.nix
            ./presets/nixos/security/sudo
            ./presets/nixos/packages/core
            ./presets/nixos/packages/encryption
            ./presets/nixos/packages/python
            # Websites
            weirdfish-server.nixosModules.${system}.default
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
          inherit self nix-homebrew inputs;
        };
        modules = [
          ./presets/darwin/misc/nix-daemon.nix
          ./systems/airberry
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dylan = import ./users/dcurgz/airberry;
            home-manager.sharedModules = [
              ./modules/common
              ./modules/home-manager/common
              ./modules/home-manager/darwin
            ];
            home-manager.extraSpecialArgs = {
              # Pass arguments to home
              inherit globals;
            };
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
          inherit self nix-homebrew;
        };
        modules = [
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
            #keylight = pkgs.local.keylight;
            weirdfish-server = pkgs.local.weirdfish-server;
          }
        );

      # Deploy-rs configuration
      deploy.nodes = {
        weirdfish-cax11-4gb = {
          hostname = "weirdfi.sh";
          sshUser = "root";
          remoteBuild = true;
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.weirdfish-cax11-4gb;
          };
        };

        hyperberry = {
          hostname = "hyperberry";
          sshUser = "dcurgz";
          remoteBuild = true;
          profiles.system = {
            user = "dcurgz";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hyperberry;
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
