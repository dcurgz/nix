{
  lib,
  ...
}:
with lib;

{
  options.by.portmap = {
    internal.anubis = mkOption {
      type = types.int;
      description = ''
        Anubis is a Web AI Firewall utility that acts as a filter proxy.

        This option defines the primary Anubis port.

        See the documentation: https://anubis.techaro.lol/docs/
      '';
    };
    internal.nginx = mkOption {
      type = types.int;
      description = ''
        Nginx is a web server and reverse proxy server.

        This option is for an internal, post-filter Nginx web server port.
      '';
    };
    internal.weirdfish = mkOption {
      type = types.int;
      description = ''
        weirdfi.sh is my personal blog.

        This option is for weirdfish-server's internal web server port.
      '';
    };
  };
}
