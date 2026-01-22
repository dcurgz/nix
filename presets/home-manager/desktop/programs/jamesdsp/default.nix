{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pkg-config
    (pkgs.writeShellScriptBin "jamesdsp" ''
      # Include libfontconfig.so
      export LD_LIBRARY_PATH="${pkgs.fontconfig.out}/lib"
      exec ${pkgs.jamesdsp}/bin/jamesdsp "$@"
    '')
  ];

  # Equalizer
  systemd.user.services = {
    jamesdsp = {
      Unit = {
        Description = "JamesDSP daemon";
        Requires = ["dbus.service"];
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target" "pipewire.service"];
      };
      Install.WantedBy = ["default.target"];
      Service = {
        ExecStart = "${pkgs.jamesdsp}/bin/jamesdsp --tray";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
