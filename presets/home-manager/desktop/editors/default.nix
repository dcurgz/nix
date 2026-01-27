{
  pkgs,
  lib,
  ...
}:
with lib;

{
  home.packages = with pkgs; [
    # Image editing
    darktable
    aseprite
  ];
}
