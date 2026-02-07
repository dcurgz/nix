{
  config,
  lib,
  pkgs,
  ...
}:

let
  keys = import ../../keys { };

  by = config.by.constants;
  inherit (by) NIXOS_PRESETS;
in
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalization properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "uk";
  };

  # Enable sudo.
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.resolved = {
    enable = true;
  };

  # Setup networking.
  networking = {
    hostName = "fooberry";
    enableIPv6 = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    firewall = {
      enable = true;
    };
  };

  # Define users.
  users.users.dcurgz = {
    isNormalUser = true;
    group = "dcurgz";
    extraGroups = [
      "wheel"
    ];
    home = "/home/dcurgz";
  };
  users.groups.dcurgz = { };
  nix.settings.trusted-users = [ "dcurgz" ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = lib.mkDefault "both";

  programs.command-not-found.enable = true;

  by.configure-ssh = {
    enable = true;
    groups = [
      {
        users = [ "root" "dcurgz" ];
        keys = keys.ssh.groups.privileged;
      }
    ];
  };

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "25.05";
}
