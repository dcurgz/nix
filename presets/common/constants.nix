{ config, ... }:

{
  config.by.constants.hosts = {
    hyperberry =
      let
        s = config.by.secrets.hyperberry;
      in
      {
        networking = {
          tailscale.address = s.tailscale.address;
        };
        ssh.user = "dcurgz";
      };
    miniberry =
      let
        s = config.by.secrets.miniberry;
      in
      {
        networking = {
          tailscale.address = s.tailscale.address;
        };
        ssh.user = "dcurgz";
      };
    piberry =
      let
        s = config.by.secrets.piberry;
      in
      {
        networking = {
          tailscale.address = s.tailscale.address;
        };
        ssh.user = "piberry";
      };
  };
}
