
{ pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      rustup
      cmake
      gcc
      gnumake
      go
      nodejs
      pkg-config
      rustc
    ];
}
