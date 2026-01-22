{ ... }:

{
  my-hosts = {
    hyperberry = {
      tailscale.address = "";
    }
    miniberry = {
      tailscale.address = "";
    };
    piberry = {
      tailscale.address = "";
      nginx = {
        domain = "";
        subdomain = "";
        acme.email = "";
      };
    };
  };
}
