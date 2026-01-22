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

  home.username = "dcurgz";

  imports = [
    "${HM_PRESETS}/packages/core"
    "${HM_PRESETS}/packages/compilers"
    "${HM_PRESETS}/desktop/fonts"
    "${HM_PRESETS}/desktop/programs/fish"
  ];

  by.programs.alacritty.enable = true;

  programs.home-manager.enable = true;
}
