{
  pkgs,
  ...
}:

{
  programs.dankMaterialShell = {
    enable = true;
    niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };
  };
}
