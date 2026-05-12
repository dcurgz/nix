{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.home-manager.dank-material-shell = flake.lib.home-manager.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
      imports = [
        inputs.dankMaterialShell.homeModules.dank-material-shell
        inputs.dankMaterialShell.homeModules.niri
      ];

      programs.dankMaterialShell = {
        enable = true;
        settings = builtins.fromJSON (builtins.readFile ./dms.settings.json);
        niri = {
          enableKeybinds = true;
          enableSpawn = true;
        };
      };
    });
}
