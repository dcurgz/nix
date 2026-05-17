{
  inputs,
  lib,
  ...
} @args:

# A set of packages that should be present on personal workstations.
let
  inherit (args.config) flake;

  mkPackages = system: pkgs: with pkgs; [
    # Python
    python313
    uv
    # Android
    apksigner
    # Nix
    direnv
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific packages
  ]) ++ (lib.optionals pkgs.stdenv.isDarwin [
    # Darwin-specific packages
    libiconv
  ]);
in
{
  flake.modules.nixos.packages-workstation = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-workstation ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      environment.systemPackages = mkPackages pkgs.system pkgs;
    });

  flake.modules.darwin.packages-workstation = flake.lib.darwin.mkAspect (with flake.tags; [ darwin-workstation ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      environment.systemPackages = mkPackages pkgs.system pkgs;
    });

  # Intended for standalone home-manager deployments, though I don't use this ATM.
  flake.modules.home-manager.packages-workstation = flake.lib.home-manager.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      home.packages = mkPackages pkgs.system pkgs;
    });
}
