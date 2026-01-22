
{ pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      cargo
      cmake
      gcc
      gnumake
      go
      nodejs
      pkg-config
      rustc
    ];
}
