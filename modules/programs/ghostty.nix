{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.home-manager.ghostty = flake.lib.home-manager.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    let
      cfg = config.by.programs.ghostty;
    in
    {
      options.by.programs.ghostty = {
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = pkgs.ghostty;
          description = "The ghostty package to use.";
        };
      };

      config = {
        programs.ghostty.enable = true;
        programs.ghostty.package = cfg.package;

        programs.ghostty.enableFishIntegration = true;
        programs.ghostty.settings = {
          font-size = 15;
          font-family = "Maple Mono NF";
          font-style = "Regular";
          command = lib.getExe pkgs.fish;
          shell-integration-features = "ssh-env";
        };
      };
    });
}
