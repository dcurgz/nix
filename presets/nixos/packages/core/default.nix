{
  pkgs,
  ...
}:

{
  # Make these packages available in every host, container and virtual machine.
  environment.systemPackages = with pkgs; [
    bridge-utils
    dig
    docker
    docker-compose
    #dropbox-cli
    git
    gnumake
    go
    #intentrace
    iproute2
    #jdk21_headless
    #jdk23_headless
    nginx
    powertop
    ripgrep
    speedtest-cli
    tcpdump
    tmux
    tree
    vim
    which
  ];
}
