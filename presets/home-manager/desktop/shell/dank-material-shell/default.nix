{
  pkgs,
  ...
}:

{
  programs.dankMaterialShell = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
    niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };
  };
}
