{
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) HM_PRESETS;
in
{
  home.stateVersion = "25.05";

  home.username = "dylan";
  home.homeDirectory = "/Users/dylan";

  imports = [
    "${HM_PRESETS}/desktop/fonts"
    "${HM_PRESETS}/packages/compilers"
    "${HM_PRESETS}/packages/core"
    "${HM_PRESETS}/desktop/programs/fish"
    "${HM_PRESETS}/desktop/programs/vim"
    "${HM_PRESETS}/desktop/programs/firefox"
  ];

  programs.home-manager.enable = true;


  by.programs.alacritty.enable = true;
  by.programs.alacritty.package = null;
}
