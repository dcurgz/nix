{
  pkgs ? import <nixpkgs> { },
}:

{
  twitch-chat-cli = pkgs.callPackage ./package.nix { };
}
