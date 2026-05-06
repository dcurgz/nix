{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.nixos.git = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-desktop ])
    ({
      lib,
      config,
      ...
    }:

    let
      inherit (config.networking) hostName;
    in
    {
      programs.git.enable = true;
      programs.git.config = {
        user.email = "me+git@curz.sh";
        user.name = "Dylan C";
      };
    });

  flake.modules.darwin.git = flake.lib.darwin.mkAspect (with flake.tags; [ darwin-desktop ])
    ({
      lib,
      config,
      ...
    }:

    {
      # TODO
    });
}
