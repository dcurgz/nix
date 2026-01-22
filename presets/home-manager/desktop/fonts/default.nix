{ pkgs, ... }:

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
}
