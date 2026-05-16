{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.flake = false;
    flake-compat.url = "github:NixOS/flake-compat";
  };

  outputs = { nixpkgs, ... } @inputs:
    let
      forAllSystems = f:
        (nixpkgs.lib.genAttrs
          [ "x86_64-linux" "aarch64-linux" ]
          (system: f nixpkgs.legacyPackages.${system}));
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./. { };
      });
    };
}
