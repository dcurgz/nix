{
  lib,
  ...
}:
with lib;

{
  options.by.secrets = {
    hosts = mkOption {
      type = types.attrsOf (types.submodule ({ config, name, ... }: {
        options = {
          ssh = {
            host = mkOption {
              type = types.str;
              description = "The SSH host configuration name.";
            };
            hostname = mkOption {
              type = types.str;
              description = "The SSH hostname to connect to.";
            };
            user = mkOption {
              type = types.str;
              description = "The SSH username to connect with.";
            };
          };
        };
      }));
    };
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
    weirdfish-acme = {
      email = mkOption {
        description = "The email address with which to perform automatic certificate generation.";
        type = types.str;
      };
    };
  };
}
