{
  inputs,
  lib,
  ...
} @args:

# A set of baseline packages that should be present everywhere.
let
  inherit (args.config) flake;

  mkPackages = system: pkgs: with pkgs; [
    busybox
    git
    ripgrep
    tmux
    tree
    vim
    which
    # Network
    dig
    gnumake
    iproute2
    speedtest-cli
    tcpdump
    # System
    btop
    fastfetch
    powertop
    # Nix
    nix-output-monitor
    # Encryption
    inputs.agenix.packages.${system}.agenix
    git-crypt
    gnupg
    gocryptfs
    pinentry-curses
    # Python
    python313
    uv
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific packages
  ]) ++ (lib.optionals pkgs.stdenv.isDarwin [
    # Darwin-specific packages
    libiconv
  ]);
in
{
  flake.modules.nixos.packages-core = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      environment.systemPackages = mkPackages pkgs.system pkgs;
    });

  flake.modules.darwin.packages-core = flake.lib.darwin.mkAspect []
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
  flake.modules.home-manager.packages-core = flake.lib.home-manager.mkAspect []
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
