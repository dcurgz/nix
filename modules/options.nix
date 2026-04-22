{
  inputs,
  lib,
  ...
}@args:

let
  inherit (args.config) flake; 
  unspecified = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = { };
  };
in
{
  # These options are in global (flake-parts class) scope.
  # 'by' is the *berry namespace, defining custom options for dcurgz's flake configuration.
  options.by = {
    # An attrset of various git-crypt secrets.
    git-secrets = unspecified;
    # An attrset of program options, which are implemented by NixOS, nix-darwin or home-manager modules.
    programs = unspecified;
    # An attrset of service options, which are implemented by NixOS, nix-darwin or home-manager modules.
    services = unspecified;
  };

  config = {
    flake.modules.nixos.by =
      _args:

      {
        options.by = {
          # An attrset of hostnames, where each value is an attrset of constants associated with that host.
          host-constants = unspecified;
        };
      };

    flake.modules.nixos.flake-default.imports = with flake.modules; lib.mkMerge [ nixos.by ];
  };
}
