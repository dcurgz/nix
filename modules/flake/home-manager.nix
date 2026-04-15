{
  inputs,
  ...
}:

let
  inherit (inputs.self) flake;
in
{
  flake.modules.nixos.home-manager'' =
    {
      user ? "dcurgz",
      modules ? [ ],
    }:

    {
      lib,
      ...
    }:

    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ]; 

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";
      home-manager.users.${user} = {
        home.username = "${user}";
        home.homeDirectory = "/home/${user}";
        programs.home-manager.enable = true;
      };
      home-manager.sharedModules = modules;
    };

  flake.modules.darwin.home-manager'' =
    {
      user ? "dcurgz",
      modules ? [ ],
    }:

    {
      lib,
      ...
    }:

    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ]; 

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";
      home-manager.users.${user} = {
        home.username = "${user}";
        home.homeDirectory = "/Users/${user}";
        programs.home-manager.enable = true;
      };
      home-manager.sharedModules = modules;
    };
}
