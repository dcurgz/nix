{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.home-manager.git = flake.lib.home-manager.mkAspect (with flake.tags; [ nixos-base darwin-base ])
    ({
      lib,
      config,
      ...
    }:

    let
      inherit (config.by.host-constants) hostName;
    in
    {
      programs.git = {
        enable = true;
        settings = {
          user.email = "${hostName}@curz.sh";
          user.name = "Dylan Curzon";
        };
      };
    });
}
