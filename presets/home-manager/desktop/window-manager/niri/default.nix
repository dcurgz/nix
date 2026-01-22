{ config, pkgs, ... }:

let
  browser = "firefox";
  file-explorer = "nemo";
  bluetooth-manager = "blueman-manager";
  sound-manager = "pavucontrol";
  terminal = "alacritty";
  app-launcher = "fuzzel";
in
{
  home.packages = with pkgs; [
    fuzzel
    libnotify
    swww
    wlsunset
    xwayland-satellite
    nfsm
    nfsm-cli

    nemo
    blueman
    pavucontrol
    alacritty
    fuzzel
  ];

  programs.niri.enable = true;

  programs.niri.settings.binds = {
    # application shortcuts
    "Mod+B".action.spawn = browser;
    "Mod+E".action.spawn = file-explorer;
    "Mod+Shift+B".action.spawn = bluetooth-manager;
    "Mod+Shift+P".action.spawn = sound-manager;
    "Mod+Return".action.spawn = terminal;
    "Mod+D".action.spawn = app-launcher;

    # desk
    "Mod+Insert".action.spawn = ["keylight" "--color" "-33"];
    "Mod+Delete".action.spawn = ["keylight" "--color" "+33"];
    "Mod+Page_Down".action.spawn = ["keylight" "--brightness" "-10"];
    "Mod+Page_Up".action.spawn = ["keylight" "--brightness" "+10"];

    # actions
    "Mod+Ctrl+WheelScrollDown" = {
      action.focus-workspace-down = {};
      cooldown-ms = 300;
    };
    "Mod+Ctrl+WheelScrollUp" = {
      action.focus-workspace-up = {};
      cooldown-ms = 300;
    };
    "Mod+WheelScrollDown" = {
      action.focus-column-right = {};
      cooldown-ms = 50;
    };
    "Mod+WheelScrollUp" = {
      action.focus-column-left = {};
      cooldown-ms = 50;
    };
    "Mod+BracketLeft".action.consume-or-expel-window-left = {};
    "Mod+BracketRight".action.consume-or-expel-window-right = {};
    "Mod+W".action.switch-preset-column-width = {};
    "Mod+W".cooldown-ms = 300;
    "Mod+F".action.maximize-column = {};
    "Mod+Shift+F".action.spawn = "nfsm-cli"; # Niri fullscreen manager
    "Mod+Ctrl+F".action.expand-column-to-available-width = {};
    "Mod+Shift+S".action.screenshot = {};
    "Mod+Shift+E".action.quit = {};
    "Mod+Shift+Q".action.close-window = {};
  };

  programs.niri.settings.spawn-at-startup = [
    { argv = ["nfsm"]; }
    { argv = ["swww-daemon"]; }
    { argv = ["way-displays"]; }
    { argv = ["wlsunset"]; }
    { argv = ["xwayland-satellite"]; }
  ];

  programs.niri.settings.prefer-no-csd = true;

  programs.niri.settings.layout.gaps = 2;
  programs.niri.settings.layout.preset-column-widths = [
    { proportion = 1. / 3.; }
    { proportion = 1. / 2.; }
  ];
  programs.niri.settings.layout.default-column-width = { proportion = 1. / 2.; };
  programs.niri.settings.layout.border.enable = false;

  programs.niri.settings.input.warp-mouse-to-focus = true;
  programs.niri.settings.input.focus-follows-mouse.enable = true;
  programs.niri.settings.input.focus-follows-mouse.max-scroll-amount = "0%";
  programs.niri.settings.input.keyboard.xkb.layout = "gb";
  programs.niri.settings.input.keyboard.repeat-delay = 225;
  programs.niri.settings.input.keyboard.repeat-rate = 20;
  programs.niri.settings.input.mouse.accel-speed = -1;

  #home.file.".config/niri/config.kdl".source = ./niri.kdl;

  #systemd.user.services.niri = {
  #  Unit = {
  #    Description = "A scrollable-tiling Wayland compositor";
  #    BindsTo = [ "graphical-session.target" ];
  #    Before = [
  #      "graphical-session.target"
  #      "xdg-desktop-autostart.target"
  #    ];
  #    Wants = [
  #      "graphical-session-pre.target"
  #      "xdg-desktop-autostart.target"
  #    ];
  #    After = [ "graphical-session-pre.target" ];
  #  };
  #  Service = {
  #    Slice = "session.slice";
  #    Type = "notify";
  #    ExecStart = "${pkgs.niri}/bin/niri --session";
  #  };
  #};
}
