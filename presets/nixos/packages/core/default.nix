{
  pkgs,
  ...
}:

{
  # Make these packages available in every host, container and virtual machine.
  environment.systemPackages = with pkgs; [
    bridge-utils
    dig
    git
    gnumake
    go
    iproute2
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
