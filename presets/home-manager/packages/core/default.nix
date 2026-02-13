{ pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      # Local bin scripts ($NIX_HOME/bin)
      local-scripts
      # My programs
      #local.keylight

      # Core utilities
      bc
      btop
      coreutils
      diffutils
      file
      findutils
      gawk
      git
      gnugrep
      gnused
      hexdump
      htop
      less
      patch
      rsync
      tmux
      tree
      which
      xxd
      gron

      # Modern terminal tools
      bat
      delta
      eza
      ripgrep
      fd

      # Modern scripting
      zx # github:google/zx

      # AI/LLM tools
      (python312.withPackages (ps: with ps; [
        llm
        llm-openrouter
        llm-github-copilot
      ]))

      # Text processing and viewers
      glow # Markdown viewer
      nano
      jq

      # Network tools
      curl
      netcat-gnu
      socat
      wget

      # Compression
      bzip2
      git-crypt
      gnutar
      gzip
      unzip
      xz
      zip

      # Encryption and security
      openssl
      age
      sqlite
      gnupg

      #android
      android-tools
      aapt
      apksigner

      # Nix stuff
      nix-index
      agenix
      deploy-rs
    ]
    ++ lib.optionals stdenv.isLinux (
      with pkgs;
      [
        isd
      ]
    );
}
