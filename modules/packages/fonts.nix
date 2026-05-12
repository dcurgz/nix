{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.home-manager.packages-fonts = flake.lib.home-manager.mkAspect (with flake.tags; [ nixos-desktop darwin-desktop ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      # Reminder: if I use this long-term, buy the font.
      home.packages = with pkgs; [
        maple-mono.truetype # for IDE
        maple-mono.NF # for terminal
      ];

      fonts.fontconfig.enable = true;
      fonts.fontconfig.defaultFonts = {
        monospace = [ "Maple Mono" ];
      };
    });
}
