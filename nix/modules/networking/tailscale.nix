{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.tailscale = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
  ({
    config,
    pkgs,
    ...
  }:

  let
    pkgs' = import inputs.nixpkgs-tailscale { system = pkgs.system; };
  in
  {
    services.tailscale.package = pkgs'.tailscale;
  });
}
