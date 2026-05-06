{
  inputs,
  ...
} @args:

let
  inherit (args.config) flake;
in
{
  flake.modules.nixos.home-manager = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      _classArgs,
      ...
    }:

    let
      inherit (_classArgs) modules;
      aspects = builtins.filter (a: builtins.isAttrs a && a ? "_type" && a._type == "aspect") modules;
      homeManagerAspects = builtins.filter (aspect: aspect._type == "home-manager") (lib.lists.flatten aspects);

      cfg = config.by.presets.home-manager;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      options.by.presets.home-manager = {
        user = lib.mkOption {
          type = lib.types.str;
          default = "dcurgz";
        };
      };

      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "bak";
        home-manager.users.${cfg.user} = {
          home.username = "${cfg.user}";
          home.homeDirectory = "/home/${cfg.user}";
          home.stateVersion = "25.05";
          programs.home-manager.enable = true;
        };
        home-manager.sharedModules = builtins.map (aspect: aspect._module) homeManagerAspects;
      };
    });

  flake.modules.darwin.home-manager = flake.lib.darwin.mkAspect []
    ({
      lib,
      config,
      _classArgs,
      ...
    }:

    let
      inherit (_classArgs) aspects;
      homeManagerAspects = builtins.filter (aspect: aspect._type == "home-manager") (lib.lists.flatten aspects);

      cfg = config.by.presets.home-manager;
    in
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];

      options.by.presets.home-manager = {
        user = lib.mkOption {
          type = lib.types.str;
          default = "dcurgz";
        };
      };

      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "bak";
        home-manager.users.${cfg.user} = {
          home.username = "${cfg.user}";
          home.homeDirectory = "/Users/${cfg.user}";
          programs.home-manager.enable = true;
        };
        home-manager.sharedModules = builtins.map (aspect: aspect._module) homeManagerAspects;
      };
    });
}
