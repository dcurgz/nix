{ lib, ... }:
with lib;

{
  options.by.constants.hardware = {
    interfaces.ethernet = mkOption {
      description = "The name of the ethernet interface on this device.";
      type = types.str;
      default = "eno1";
    };
  };
}
