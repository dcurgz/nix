{
  pkgs,
  naersk',
  ...
}:
with pkgs;

{
  weirdfish-server = callPackage ./weirdfish-server { inherit naersk'; };
}
