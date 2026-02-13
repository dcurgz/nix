{
  config,
  pkgs,
  lib,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  keys = import "${FLAKE_ROOT}/keys" { inherit lib; };
  secrets = config.by.secrets;

  by = config.by.constants;
  inherit (by) NIXOS_PRESETS;
in
{
  age.secrets.wifi = {
    file = "${FLAKE_ROOT}/secrets/wg/Wi-Fi.age";
    mode = "770";
    owner = "root";
    group = "wpa_supplicant";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
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
      hostName = "tauberry";
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
        ];
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
        interface = "${wifi}";
      };
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      # Setup Wi-Fi.
      wireless = {
        enable = true;
        secretsFile = config.age.secrets.wifi.path;
        networks."Stan Chappell Roan".pskRaw = "ext:psk";
      };
    };

  services.tailscale.enable = true;

  # Enable Avahi for network service discovery.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = false;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.openssh = {
    enable = true;
  };
  by.configure-ssh = {
    enable = true;
    groups = [
      {
        users = [ "tauberry" "root" ];
        keys = keys.ssh.groups.privileged.paths;
      }
    ];
  };

  users = {
    mutableUsers = false;
    users.tauberry = {
      isNormalUser = true;
      extraGroups = [ "wheel" "data" "media" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    alsa-lib
    alsa-utils
    alsa-tools
  ];

  programs.gnupg.agent.enable = true;

  nix.settings.trusted-users = [ "tauberry" ];

  # Unsure if this actually does anything to improve the quality of mopidy streaming.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
    };
    wireplumber.enable = true;
  };

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "24.11";
}
