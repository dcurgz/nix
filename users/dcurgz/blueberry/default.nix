{ config, pkgs, globals, ... }:

let
  inherit (globals) HM_MODULES HM_PRESETS;
in
{
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
  home.username = "dcurgz";

  imports = [
    # shell
    "${HM_PRESETS}/desktop/window-manager/niri"
    "${HM_PRESETS}/desktop/shell/dank-material-shell"
    # common
    "${HM_PRESETS}/common"
    "${HM_PRESETS}/desktop/editors"
    "${HM_PRESETS}/desktop/fonts"
    # screen
    "${HM_PRESETS}/desktop/utilities/way-displays"
    # games
    "${HM_PRESETS}/desktop/games/hollow-knight"
    "${HM_PRESETS}/desktop/games/minecraft"
    "${HM_PRESETS}/desktop/games/obs"
    # utilities
    "${HM_PRESETS}/desktop/utilities/bitwarden"
    # terminal
    "${HM_PRESETS}/desktop/programs/fish"
    "${HM_PRESETS}/desktop/programs/vim"
    "${HM_PRESETS}/desktop/programs/firefox"
    "${HM_PRESETS}/desktop/programs/zed"
    # packages
    "${HM_PRESETS}/packages/compilers"
    "${HM_PRESETS}/packages/core"
    "${HM_PRESETS}/packages/socials"
  ];

  by.programs = {
    alacritty.enable = true;
    dms.enable = true;
  };
}
