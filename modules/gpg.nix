{
  inputs,
  ...
}:

{
  flake.modules.nixos.gpg = 
    {
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
    };

  flake.modules.darwin.gpg = 
    {
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
    };
}
