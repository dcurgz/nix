{ lib, ... }:
with lib;

{
  options.by.constants.hardware = {
    interfaces.ethernet = mkOption {
      type = types.str;
      default = "eno1";
      description = "The name of the ethernet interface on this device.";
    };

    interfaces.wifi = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The name of the Wi-Fi interface on this device.";
    };

    pcie.nvidia_gpu = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The PCIE GPU device address for an Nvidia card.";
    };

    pcie.nvidia_audio = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The PCIE audio device address for an Nvidia card.";
    };
  };
}
