{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.linux-builder = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      users.users.builder = {
        isNormalUser = true;
        shell = pkgs.bashInteractive;
        group = "builder";
      };
      users.groups.builder = { };

      nix.settings.trusted-users = [ "builder" ];
    });
}
