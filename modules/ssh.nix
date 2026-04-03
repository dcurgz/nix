{
  inputs,
  ...
}:

{
  flake.modules.nixos.ssh = 
    {
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
              HostName ${hostConfig.ssh.hostname}
              User ${hostConfig.ssh.user}
            '');
            hosts = (lib.mapAttrsToList mkHostConfig config.by.secrets.hosts);
        in
        {
          extraConfig = (lib.concatStringsSep "\n" hosts);
          knownHosts = keys.ssh.knownHosts;
        };
    };

  flake.modules.darwin.ssh = 
    {
      lib,
      config,
      ...
    }:

    {
      # TODO
    };
}
