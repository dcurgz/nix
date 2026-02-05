{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { flake-utils, naersk, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk { };
        package = naersk'.buildPackage ./.;
      in
      {
        packages.default = package;
        nixosModules.default = ({ config, lib, ... }:
          with lib;

          let
            cfg = config.weirdfish-server;
          in
          {
            options.services.healthcheck = {
              enable = mkEnableOption "Enable the weirdfi.sh web server.";
            };

            config = mkIf (cfg.enable) {
              systemd.services.healthcheck = {
                wantedBy = [ "multi-user.target" ];
                after = [ "network.target" ];
                script =
                  ''
                    exec ${package}/bin/healthcheck 
                  '';
              };
            };
          }
        );
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ rustc cargo ];
        };
      }
    );
}
