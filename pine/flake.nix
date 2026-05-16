{
  description = "A flake for Bench development.";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      package = pkgs.callPackage ./package.nix { };
    in
    {
      packages.default = package;
      packages.pine    = package;

      devShell = pkgs.mkShell rec {
        inherit (package) nativeBuildInputs buildInputs;
        #LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath package.buildInputs;
      };
    });
}
