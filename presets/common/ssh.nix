{
  config,
  lib,
  globals,
  ...
}:
with lib;

let
  inherit (globals) FLAKE_ROOT;
  keys = import "${FLAKE_ROOT}/keys" { inherit lib; };
in
{
  programs.ssh =
    let
      mkHostConfig = (
        hostname: hostConfig: ''
          Host ${hostConfig.ssh.host}
            HostName ${hostConfig.ssh.hostname}
            User ${hostConfig.ssh.user}
          '');
      hosts = (mapAttrsToList mkHostConfig config.by.secrets.hosts);
    in
    {
      extraConfig = (concatStringsSep "\n" hosts);
      knownHosts = keys.ssh.knownHosts;
    };
}
