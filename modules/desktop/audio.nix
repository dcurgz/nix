{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.nixos.desktop-audio = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-desktop ])
    ({
      lib,
      config,
      ...
    }:

    {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        extraConfig.pipewire = {
          # pretty sure none of this does anything
          "10-clock-rate" = {
            "default.clock.rate" = 192000;
            "default.clock.allowed-rates" = [ 192000 ];
            "default.clock.quantum" = 800;
            "default.clock.min-quantum" = 512;
            "default.clock.max-quantum" = 1024;
          };
          "11-buffers" = {
            "link.max-buffers" = 64;
          };
          "12-no-suspend" = {
            "session.suspend-timeout-seconds" = 0;
          };
        };
      };
    });
}
