{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    agenix
    git-crypt
    gnupg
    gocryptfs
    pinentry-curses
  ];
}
