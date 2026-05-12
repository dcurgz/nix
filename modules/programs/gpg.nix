{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.nixos.gpg = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = lib.mkForce pkgs.pinentry-curses;
      };
    });

  flake.modules.darwin.gpg = flake.lib.darwin.mkAspect (with flake.tags; [ darwin-base ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      programs.gnupg.agent = {
        enable = true;
      };
    });
}
