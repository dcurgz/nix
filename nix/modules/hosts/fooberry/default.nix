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
in
{
  flake.metadata.fooberry = {
    type = flake.things.host;
    description = ''
      fooberry is a 2014 Dell Inspiron laptop that now serves as a makeshift
      Tailscale subnet router for my parents' place. 
    '';
    attributes = {
      uplinks.tailscale0.ipAddress = "100.64.*.*";
      services.nginx = {
        description = ''
          I use nginx to serve an HTTPS proxy on the local network, then route
          the connection over the tailnet to the relevant service VM.
        '';
      };
    };
  };

  flake.nixosConfigurations.fooberry = flake.lib.mkNixOS rec {
    system = "x86_64-linux";
    specialArgs = {
      pkgs = prebuiltPackages.${system};
    };
    modules = with flake.modules; [
      (with flake.tags; flake.lib.use [
        flake-default
        nixos-base
      ])
      nixos.fooberry
      nixos.fooberry-hardware
      nixos.fooberry-disk
      nixos.authorized-keys
      {
        by.presets.authorized-keys.groups = [
          {
            users = [ "root" "dcurgz" ];
            keys = keys.ssh.groups.privileged.paths;
          }
        ];
      }
    ];
  };

  flake.modules.nixos.fooberry = flake.lib.nixos.mkAspect (with flake.tags; [ hosts ])
    ({
      lib,
      pkgs,
      config,
      ...
    }:

    let
      secrets = config.by.git-secrets;
    in
    {
      age.secrets.cloudflare-key.file = "${FLAKE_ROOT}/agenix-secrets/agenix/fooberry/cloudflare-key.age";
      age.secrets.wifi = {
        file = "${FLAKE_ROOT}/agenix-secrets/agenix/fooberry/Wi-Fi.age";
        mode = "770";
        owner = "root";
        group = "wpa_supplicant";
      };

      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      boot.loader.efi.canTouchEfiVariables = true;

      boot.kernelPackages = pkgs.linuxPackages_latest;

      services.upower.ignoreLid = true;
      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
      };

      time.timeZone = "Europe/London";

      i18n.defaultLocale = "en_GB.UTF-8";
      console = {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
        packages = with pkgs; [ terminus_font ];
        keyMap = "uk";
      };

      security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

      services.resolved.enable = true;

      networking = {
        hostName = "fooberry";
        enableIPv6 = true;
        firewall.enable = true;
        wireless = {
          enable = true;
          secretsFile = config.age.secrets.wifi.path;
          networks."Foobar".pskRaw = "ext:psk";
        };
      };

      # https://github.com/Gerschtli/nix-config/blob/89e15e733b97827c1a25aabf96142990d0a453bc/hosts/xenon/configuration.nix#L38
      systemd.services.wpa_supplicant.serviceConfig = {
        Restart = "always";
        RestartSec = 5;
      };

      users.users.dcurgz = {
        isNormalUser = true;
        group = "dcurgz";
        extraGroups = [ "wheel" ];
        home = "/home/dcurgz";
      };
      users.groups.dcurgz = { };
      nix.settings.trusted-users = [ "dcurgz" ];

      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "both";
      };

      programs.command-not-found.enable = true;

      networking.firewall.allowedTCPPorts = [ 80 443 ];

      services.nginx =
        let
          destination = "100.91.239.123";
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
        certs."${secrets.fooberry-proxy.subdomain}" = {
          domain = "*.${secrets.fooberry-proxy.domain}";
          group = "nginx";
          dnsProvider = "cloudflare";
          environmentFile = config.age.secrets.cloudflare-key.path;
        };
      };

      system.stateVersion = "25.05";
    });

  flake.deploy.nodes.fooberry = {
    hostname = "fooberry";
    sshUser = "dcurgz";
    remoteBuild = false;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos flake.nixosConfigurations.fooberry;
    };
  };
}
