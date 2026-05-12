{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.dns = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    let
      upstream = [
        # cloudflare
        "sdns://AgcAAAAAAAAABzEuMS4xLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5" # 1.1.1.1
        "sdns://AgcAAAAAAAAABzEuMC4wLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5" # 1.0.0.1
        "sdns://AgcAAAAAAAAAFlsyNjA2OjQ3MDA6NDcwMDo6MTExMV0AIDFkb3QxZG90MWRvdDEuY2xvdWRmbGFyZS1kbnMuY29tCi9kbnMtcXVlcnk" # [2606:4700:4700::1111]
        "sdns://AgcAAAAAAAAAFlsyNjA2OjQ3MDA6NDcwMDo6MTAwMV0AIDFkb3QxZG90MWRvdDEuY2xvdWRmbGFyZS1kbnMuY29tCi9kbnMtcXVlcnk" # [2606:4700:4700::1001]
      ];
      fallback = [
        # quad9
        "sdns://AgcAAAAAAAAABzkuOS45LjkADWRucy5xdWFkOS5uZXQKL2Rucy1xdWVyeQ" # 9.9.9.9
        "sdns://AgcAAAAAAAAADzE0OS4xMTIuMTEyLjExMgANZG5zLnF1YWQ5Lm5ldAovZG5zLXF1ZXJ5" # 149.112.112.112
        "sdns://AgcAAAAAAAAADVsyNjIwOmZlOjpmZV0ADWRucy5xdWFkOS5uZXQKL2Rucy1xdWVyeQ" # [2620:fe::fe]
        "sdns://AgcAAAAAAAAADFsyNjIwOmZlOjo5XQANZG5zLnF1YWQ5Lm5ldAovZG5zLXF1ZXJ5" # [2620:fe::9]
      ];
    in
    {
      networking = {
        nameservers = [
          "127.0.0.55"
        ];
        dhcpcd.extraConfig = "nohook resolv.conf";
      };

      services.dnsproxy = {
        enable = true;
        settings = {
          inherit upstream fallback;
          listen-addrs = [ "127.0.0.55" ];
        };
        flags = [ "--cache" ];
      };

      services.resolved.settings = {
        Resolve = {
          FallbackDNS = [ "127.0.0.55" ];
        };
      };
    });

  flake.modules.darwin.dns = flake.lib.darwin.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
      #TODO
    });
}
