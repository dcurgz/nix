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
  home.homeDirectory = "/Users/dcurgz";

  imports = [
    "${HM_PRESETS}/packages/core"
    "${HM_PRESETS}/packages/compilers"
    "${HM_PRESETS}/desktop/programs/vim"
    "${HM_PRESETS}/desktop/programs/fish"
  ];

  programs.home-manager.enable = true;
}
