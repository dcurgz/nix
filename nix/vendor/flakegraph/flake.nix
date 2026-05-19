{
  description = "A flake for Bench development.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      package = pkgs.callPackage ./package.nix { };
    in
    {
      packages.default = package;
      packages.flakegraph = package;

      devShell = pkgs.mkShell rec {
        inherit (package) nativeBuildInputs buildInputs;
      };
    });
}
