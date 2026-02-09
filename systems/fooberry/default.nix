{
  config,
  lib,
  pkgs,
  globals,
  ...
}:

let
  keys = import ../../keys { };

  by = config.by.constants;
  secrets = config.by.secrets;
  inherit (by) NIXOS_PRESETS;
  inherit (globals) FLAKE_ROOT;
in
{
  age.secrets.cloudflare-key.file = "${FLAKE_ROOT}/secrets/fooberry/cloudflare-key.age";
  age.secrets.wifi.file = "${FLAKE_ROOT}/secrets/fooberry/Wi-Fi.age";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Ignore lid
  services.upower.ignoreLid = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
  };

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
    firewall = {
      enable = true;
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  # Setup Wi-Fi.
  networking.wireless = {
    enable = true;
    secretsFile = config.age.secrets.wifi.path;
    networks."Foobar".pskRaw = "ext:psk";
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

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx =
    let
      destination = secrets.hosts.vm-jellyfin.ssh.hostname;
    in
    {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."${secrets.fooberry-proxy.subdomain}" = {
        forceSSL = false;
        enableACME = true;
        acmeRoot = null;
        locations."/" = {
          proxyPass = "http://${destination}";
          proxyWebsockets = true;
        };
      };
    };

  security.acme = {
    acceptTerms = true;
    defaults.email = secrets.fooberry-proxy.acme.email;
    certs = {
      "${secrets.fooberry-proxy.subdomain}" = {
        domain = "*.${secrets.fooberry-proxy.domain}";
        group = "nginx";
        dnsProvider = "cloudflare";
# location of your CLOUDFLARE_DNS_API_TOKEN=[value]
        environmentFile = config.age.secrets.cloudflare-key.path;
      };
    };
  };

  ##########################################################################################
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # In the vast majority of cases, do not change this version.
  ##########################################################################################
  system.stateVersion = "25.05";
}
