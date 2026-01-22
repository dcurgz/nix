{
  pkgs,
  ...
}:

{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    extraConfig.pipewire = {
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
}
