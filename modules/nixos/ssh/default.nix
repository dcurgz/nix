{ config, lib, ... }:

with lib;
let
  keys = (import ../../keys { });
  cfg = config.by.configure-ssh;

  group = types.submodule {
    options = {
      users = mkOption {
        description = "The users that can be used to login to ssh.";
        type = types.listOf types.str;
        default = [ "dcurgz" ];
      };
      keys = mkOption {
        description = "The list of keys that should be granted access to each user.";
        type = types.listOf types.path;
        default = [ ];
      };
    };
  };
in
{
  options.by.configure-ssh = {
    enable = mkEnableOption "Enable automatic ssh key configuration.";
    groups = mkOption {
      description = "A list of ssh key configuration groups.";
      type = types.listOf group;
    };
  };

  config.users.users = mkIf cfg.enable (
    mkMerge (builtins.map (group:
      mkMerge (builtins.map (user:
        {
          ${user}.openssh.authorizedKeys.keyFiles = group.keys;
        }
      ) group.users)
    ) cfg.groups));
}
