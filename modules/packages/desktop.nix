{
  inputs,
  lib,
  ...
} @args:

let
  inherit (args.config) flake;

  mkPackages = system: pkgs: with pkgs; [
    # Terminal
    bat
    delta
    eza
    ripgrep
    fd
    glow
    jq
    age
    android-tools
    # Compilers
    cmake
    gcc
    gnumake
    go
    nodejs
    pkg-config
    rustup
    # Nix
    nix-index
    nix-forecast
    # System management
    deploy-rs
    # AI stuff
    llm
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific packages
    bitwarden-desktop
    isd
    socat
  ]) ++ (lib.optionals pkgs.stdenv.isDarwin [
    # Darwin-specific packages
  ]);
in
{
  flake.modules.home-manager.packages-desktop = flake.lib.home-manager.mkAspect (with flake.tags; [ nixos-desktop darwin-desktop ])
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
