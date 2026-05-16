{
  inputs,
  lib,
  ...
} @args:
let
  inherit (args.config) flake;
in
{
  flake.modules.nixos.ssh = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      ...
    }:

    let
      inherit (config.by) keys;
    in
    {
      programs.ssh =
        let
          mkHostConfig = (
            hostname: hostConfig: ''
              Host ${hostConfig.ssh.host}
              HostName ${hostConfig.ssh.hostName}
              User ${hostConfig.ssh.user}
            '');
            hosts = (lib.mapAttrsToList mkHostConfig config.by.git-secrets.hosts);
        in
        {
          extraConfig = (lib.concatStringsSep "\n" hosts);
          knownHosts = keys.ssh.knownHosts;
        };
    });

  flake.modules.darwin.ssh = flake.lib.darwin.mkAspect (with flake.tags; [ darwin-base ])
    ({
      lib,
      config,
      ...
    }:

    let
      inherit (config.by) keys;
    in
    {
      programs.ssh =
        let
          mkHostConfig = (
            hostname: hostConfig: ''
              Host ${hostConfig.ssh.host}
              HostName ${hostConfig.ssh.hostName}
              User ${hostConfig.ssh.user}
            '');
            hosts = (lib.mapAttrsToList mkHostConfig config.by.git-secrets.hosts);
        in
        {
          extraConfig = (lib.concatStringsSep "\n" hosts);
          knownHosts = keys.ssh.knownHosts;
        };
      });
}
