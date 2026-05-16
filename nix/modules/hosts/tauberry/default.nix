{
  inputs,
  lib,
  globals,
  prebuiltPackages,
  ...
} @args:

let
  inherit (globals) FLAKE_ROOT;
  inherit (args.config) flake;
  inherit (args.config.by) keys;
  
  hostName = "tauberry";
in
{
  #TODO nixos-raspberrypi
  flake.nixosConfigurations.tauberry = flake.lib.mkNixOS rec {
    system = "aarch64-linux";
    specialArgs = {
      pkgs = prebuiltPackages.${system};
    };
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        nixos-base
        raspberry-pi
      ])
      nixos.tauberry
      nixos.tauberry-hardware
      nixos.authorized-keys
      {
        by.presets.authorized-keys.groups = [
          {
            users = [ "tauberry" "root" ];
            keys = keys.ssh.groups.privileged.paths;
          }
        ];
      }
      # Linux
      nixos.avahi
    ];
  };

  flake.modules.nixos.tauberry = flake.lib.nixos.mkAspect (with flake.tags; [ hosts ])
    ({
      lib,
      pkgs,
      config,
      ...
    }:

    let
      by = config.by.host-constants;
    in
    {
      age.secrets.wifi = {
        file = "${FLAKE_ROOT}/agenix-secrets/agenix/wg/Wi-Fi.age";
        mode = "770";
        owner = "root";
        group = "wpa_supplicant";
      };

      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
      };

      security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };

      networking =
        let
          wifi = by.hardware.interfaces.wifi;
        in
        {
          inherit hostName;
          firewall = {
            enable = true;
            allowedTCPPorts = [ 22 ];
          };
          interfaces."${wifi}" = {
            ipv4.addresses = [
              {
                address = "192.168.0.13";
                prefixLength = 24;
              }
            ];
          };
          defaultGateway = {
            address = "192.168.0.1";
            interface = wifi;
          };
          wireless = {
            enable = true;
            secretsFile = config.age.secrets.wifi.path;
            networks."Stan Chappell Roan".pskRaw = "ext:psk";
          };
        };

      services.openssh.enable = true;

      users = {
        mutableUsers = false;
        users.tauberry = {
          isNormalUser = true;
          extraGroups = [ "wheel" "data" "media" "pipewire" ];
        };
      };

      environment.systemPackages = with pkgs; [
        vim
        alsa-lib
        alsa-utils
        alsa-tools
      ];

      nix.settings.trusted-users = [ "tauberry" ];

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        extraConfig.pipewire = {
          "10-clock-rate" = {
            "default.clock.rate" = 192000;
            "default.clock.allowed-rates" = [ 192000 ];
            "default.clock.quantum" = 800;
            "default.clock.min-quantum" = 512;
            "default.clock.max-quantum" = 1024;
          };
          "11-buffers" = {
            "link.max-buffers" = 64;
          };
          "12-no-suspend" = {
            "session.suspend-timeout-seconds" = 0;
          };
          "13-apply-EQ" = {
            "context.modules" = [
              {
                name = "libpipewire-module-parametric-equalizer";
                args = {
                  "node.description" = "Marshall Woburn III correction curve, measured in wg-lounge on 20260214.";
                  "media.name" = "Marshall Woburn III EQ";
                  "equalizer.filepath" = ./woburn_III_EQ.txt;
                  "capture.props" = {
                    "node.name" = "alsa_output.platform-soc_sound.stereo-fallback";
                  };
                  "playback.props" = {
                    "node.name" = "alsa_output.platform-soc_sound.stereo-fallback";
                  };
                };
              }
            ];
          };
        };
        wireplumber.enable = true;
      };

      services.pipewire.systemWide = true;
      services.pipewire.pulse.enable = true;

      users.groups.mopidy = {};
      users.users.mopidy = {
        group = "mopidy";
        isSystemUser = true;
        extraGroups = [ "pipewire" ];
      };
      systemd.services.mopidy.serviceConfig.SupplementaryGroups = [ "pipewire" ];

      age.secrets.tailscale-auth-key.file = "${FLAKE_ROOT}/agenix-secrets/agenix/tailscale/hosts/${hostName}.age";
    
      services.tailscale = {
        enable = true; 
        authKeyFile = config.age.secrets.tailscale-auth-key.path;
        useRoutingFeatures = lib.mkDefault "both";
      };

      system.stateVersion = "24.11";
    });

  flake.deploy.nodes.tauberry = {
    hostname = "tauberry";
    sshUser = "tauberry";
    remoteBuild = false;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos flake.nixosConfigurations.tauberry;
    };
  };
}
