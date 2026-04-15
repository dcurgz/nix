{
  inputs,
  lib,
  ...
}:

# A set of baseline packages that should be present everywhere.
let
  mkPackages = pkgs: with pkgs; [
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
    agenix
    git-crypt
    gnupg
    gocryptfs
    pinentry-curses
    # Python
    python313
    uv
  ] // (lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific packages
  ]) // (libs.optionals pkgs.stdenv.isDarwin [
    # Darwin-specific packages
    libiconv
  ]);
in
{
  flake.modules.nixos.packages-core = 
    {
      lib,
      config,
      pkgs,
      ...
    }:

    {
      environment.systemPackages = mkPackages pkgs;
    };

  flake.modules.darwin.packages-core = 
    {
      lib,
      config,
      pkgs,
      ...
    }:

    {
      environment.systemPackages = mkPackages pkgs;
    };

  # Intended for standalone home-manager deployments, though I don't use this ATM.
  flake.modules.home-manager.packages-core = 
    {
      lib,
      config,
      pkgs,
      ...
    }:

    {
      home.packages = mkPackages pkgs;
    };
}
