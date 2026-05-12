{
  inputs,
  lib,
  ...
} @args:

# A set of baseline packages that should be present everywhere.
let
  inherit (args.config) flake;

  mkPackages = system: pkgs: with pkgs; [
    age
    bzip2
    coreutils
    curl
    diffutils
    file
    findutils
    gawk
    git
    glow
    gnugrep
    gnused
    gnutar
    hexdump
    nano
    p7zip
    ripgrep
    tmux
    tree
    unzip
    usbutils
    vim
    wget
    which
    zip
    # Modern tools
    bat
    dust
    delta
    fd
    eza
    gron
    jq
    mmv
    zx
    # Network
    dig
    gnumake
    netcat-gnu
    speedtest-cli
    sshfs
    tcpdump
    # System
    btop
    fastfetch
    # Nix
    nix-index
    nix-output-monitor
    nix-weather
    # Encryption
    inputs.agenix.packages.${system}.agenix
    git-crypt
    gnupg
    gocryptfs
    #pinentry-curses
    # Python
    python313
    uv
    # Android
    apksigner
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific packages
    busybox
    iproute2
    powertop
  ]) ++ (lib.optionals pkgs.stdenv.isDarwin [
    # Darwin-specific packages
    libiconv
  ]);
in
{
  flake.modules.nixos.packages-core = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      environment.systemPackages = mkPackages pkgs.system pkgs;
    });

  flake.modules.darwin.packages-core = flake.lib.darwin.mkAspect (with flake.tags; [ darwin-base ])
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
