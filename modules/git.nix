{
  inputs,
  ...
}:

{
  flake.modules.nixos.git' = 
    {
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
    };

  flake.modules.darwin.git' = 
    {
      lib,
      config,
      ...
    }:

    {
      # TODO
    };
}
