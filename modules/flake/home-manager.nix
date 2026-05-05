{
  inputs,
  ...
}:

let
  inherit (inputs.self) flake;
in
{
  flake.modules.nixos.home-manager' =
    {
      user ? "dcurgz"
    }:

    {
      lib,
      _flakeArgs,
      ...
    }:

    let
      inherit (_flakeArgs) aspects;
      homeManagerAspects = builtins.filter (aspect: aspect._type == "home-manager") aspects;
    in
    flake.lib.mkAspect { class = "nixos"; }
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
      home-manager.sharedModules = builtins.map (aspect: aspect._module) homeManagerAspects;
    };

  flake.modules.darwin.home-manager' =
    {
      user ? "dcurgz"
    }:

    {
      lib,
      _flakeArgs,
      ...
    }:

    let
      inherit (_flakeArgs) aspects;
      homeManagerAspects = builtins.filter (aspect: aspect._type == "home-manager") aspects;
    in
    flake.lib.mkAspect { class = "darwin"; }
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
      home-manager.sharedModules = builtins.map (aspect: aspect._module) homeManagerAspects;
    };
}
