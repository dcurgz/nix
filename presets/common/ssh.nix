{
  config,
  lib,
  ...
}:
with lib;

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
    };
}
