{
  inputs,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;
  sshOptions = {
    enable = lib.mkEnableOption "Enable ssh key configuration.";
    groups = lib.mkOption {
      description = "A list of ssh key configuration groups.";
      type = lib.types.listOf (lib.types.submodule {
        options = {
          users = lib.mkOption {
            description = "The users that can be used to login to ssh.";
            type = lib.types.listOf lib.types.str;
            default = [ "dcurgz" ];
          };
          keys = lib.mkOption {
            description = "The list of keys that should be granted access to each user.";
            type = lib.types.listOf lib.types.path;
            default = [ ];
          };
        };
      });
    };
  };
in
{
  flake.modules.nixos.ssh = 
    {
      lib,
      config,
      ...
    }:

    let
      inherit (config.by) keys;
      cfg = config.by.programs.ssh;
    in
    {
      options.by.programs.ssh = sshOptions;

      config.programs.ssh =
        let
          mkHostConfig = (
            hostname: hostConfig: ''
              Host ${hostConfig.ssh.host}
              HostName ${hostConfig.ssh.hostname}
              User ${hostConfig.ssh.user}
            '');
            hosts = (lib.mapAttrsToList mkHostConfig config.by.git-secrets.hosts);
        in
        {
          extraConfig = (lib.concatStringsSep "\n" hosts);
          knownHosts = keys.ssh.knownHosts;
        };

        config.users.users = lib.mkIf cfg.enable (
          lib.mkMerge (builtins.map (group:
            lib.mkMerge (builtins.map (user:
              {
                ${user}.openssh.authorizedKeys.keyFiles = group.keys;
              }
            ) group.users)
          ) cfg.groups));
    };

  flake.modules.darwin.ssh = 
    {
      lib,
      config,
      ...
    }:

    let
      inherit (config.by) keys;
      cfg = config.by.programs.ssh;
    in
    {
      options.by.programs.ssh = sshOptions;

      config.programs.ssh =
        let
          mkHostConfig = (
            hostname: hostConfig: ''
              Host ${hostConfig.ssh.host}
              HostName ${hostConfig.ssh.hostname}
              User ${hostConfig.ssh.user}
            '');
            hosts = (lib.mapAttrsToList mkHostConfig config.by.git-secrets.hosts);
        in
        {
          extraConfig = (lib.concatStringsSep "\n" hosts);
          knownHosts = keys.ssh.knownHosts;
        };

        config.users.users = lib.mkIf cfg.enable (
          lib.mkMerge (builtins.map (group:
            lib.mkMerge (builtins.map (user:
              {
                ${user}.openssh.authorizedKeys.keyFiles = group.keys;
              }
            ) group.users)
          ) cfg.groups));
      };
}
