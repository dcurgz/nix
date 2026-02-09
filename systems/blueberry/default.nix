{
  config,
  lib,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  keys = import "${FLAKE_ROOT}/keys" { inherit lib; };
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

  # (Configure in ./hardware.nix)
  # boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Enable Fail2Ban for basic intrusion prevention.
  services.fail2ban.enable = true;

  services.resolved = {
    enable = true;
  };

  # Setup networking.
  networking = {
    hostName = "blueberry";
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
    shell = pkgs.fish;
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

  programs.steam.enable = true;
  services.dbus.enable = true;

  programs.command-not-found.enable = true;
  programs.fish.enable = true;

  by.configure-ssh = {
    enable = true;
    groups = [
      {
        users = [ "root" "dcurgz" ];
        keys = keys.ssh.groups.privileged.paths;
      }
    ];
  };

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "25.05";
}
