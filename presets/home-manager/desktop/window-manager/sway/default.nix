{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  browser = "firefox";
  file-explorer = "nemo";
  bluetooth-manager = "blueman-manager";
  sound-manager = "pavucontrol";
  terminal = "ghostty";
  app-launcher = "fuzzel";
in
{
  home.packages = with pkgs; [
    fuzzel
    libnotify
    swww
    wlsunset
    nemo
    blueman
    pavucontrol
    fuzzel
  ];

  # TODO: this doesn't work
  home.sessionVariables = {
    WLR_RENDERER = "vulkan";
  };

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;
    systemd.variables = [ "WLR_RENDERER" ];
    config = {
      inherit terminal;
      modifier = "Mod4";
      keybindings = 
        let 
          mod = "Mod4";
        in
        {
          # application shortcuts
          "${mod}+B" = "exec ${browser}";
          "${mod}+E" = "exec ${file-explorer}";
          "${mod}+Shift+B" = "exec ${bluetooth-manager}";
          "${mod}+Shift+P" = "exec ${sound-manager}";
          "${mod}+Return" = "exec ${terminal}";
          "${mod}+D" = "exec ${app-launcher}";

          "${mod}+Shift+H" = "exec swaymsg output \"*\" hdr on";

          # desk
          "${mod}+Insert"    = "exec keylight --color -33";
          "${mod}+Delete"    = "exec keylight --color +33";
          "${mod}+Page_Down" = "exec keylight --brightness -10";
          "${mod}+Page_Up"   = "exec keylight --brightness +10";

          # tweaked defaults
          "${mod}+Shift+e" = ''
            exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'
          '';
          "${mod}+Shift+q" = "kill";
          "${mod}+Shift+r" = "reload";
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";
          "${mod}+h" = "splith";
          "${mod}+v" = "splitv";
          "${mod}+w" = "layout toggle split";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+f" = "fullscreen";
        };
      startup = [
        {
          command = toString (pkgs.writeShellScript "sway-startup" ''
            swww-daemon &
            way-displays &
            wlsunset &
          '');
        }
      ];
    };
    extraConfig = ''
      output * render_bit_depth 10
      output * hdr off
      
      input * {
        xkb_layout "gb"
      }
    '';
  };
}
