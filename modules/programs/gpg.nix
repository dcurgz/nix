{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.nixos.gpg = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    });

  flake.modules.darwin.gpg = flake.lib.darwin.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      # TODO: does this work?
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    });
}
