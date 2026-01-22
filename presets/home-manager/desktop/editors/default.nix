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
    # Code editors
    zed-editor
    jetbrains.idea-community
  ];
}
