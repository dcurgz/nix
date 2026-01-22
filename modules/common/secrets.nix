{ lib, ... }:
with lib;

let
  generalOptions = {
    tailscale.address = mkOption {
      description = "The tailscale MagicDNS address for this host.";
      type = types.str;
    };
  };
in
{
  options.by.secrets = {
    hyperberry = generalOptions;
    miniberry = generalOptions;
    piberry = generalOptions // {
      # Add more piberry specific secrets.
      home-assistant = {
        domain = mkOption {
          description = "The root domain that the Home Assistant instance is accessible under.";
          type = types.str;
        };
        subdomain = mkOption {
          description = "The subdomain that the Home Assistant instance is accessible under.";
          type = types.str;
        };
        acme.email = mkOption {
          description = "The email address with which to perform automatic DNS-0 SSL certificate generation.";
          type = types.str;
        };
      };
    };
    weirdfish = {
        acme.email = mkOption {
          description = "The email address with which to perform automatic certificate generation.";
          type = types.str;
        };
    };
  };
}
