{
  config,
  lib,
  pkgs,
  ...
}:

let
  keys = import ../../keys { };
  by = config.by.constants;
in
{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalization properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

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

  by.configure-ssh = {
    enable = true;
    groups = [
      {
        users = [ "root" "dcurgz" ];
        keys = keys.ssh.groups.privileged;
      }
    ];
  };

  # Enable Fail2Ban for basic intrusion prevention.
  services.fail2ban.enable = true;

  networking = {
    hostName = "weirdfish-cax11-4tb";
    enableIPv6 = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
    };
  };

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

  programs.fish.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05";
}
