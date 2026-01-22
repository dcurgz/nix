{ lib, ... }:
with lib;

let
  hostConfig = types.submodule (
    {
      options = {
        networking = {
          tailscale.address = mkOption {
            description = "The tailscale MagicDNS address for this host.";
            type = types.str;
            default = "an.imaginary.tailscale.magic.dns.address";
          };
        };
        ssh.user = mkOption {
          description = "The normal user that other hosts should use for ssh.";
          type = types.str;
          default = "dcurgz";
        };
      };
    });
in
{
  options.by.constants.hardware = {
    interfaces.ethernet = mkOption {
      description = "The name of the ethernet interface on this device.";
      type = types.str;
      default = "eno1";
    };
  };
}
