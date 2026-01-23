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
            options.weirdfish-server = {
              enable = mkEnableOption "Enable the weirdfi.sh web server.";
              listen = mkOption {
                type = types.str;
                default = "127.0.0.1:8080";
                description = "The host string to serve weirdfi.sh on.";
              };
              webroot = mkOption {
                type = types.path;
                description = "A path to the weirdfi.sh resource webroot.";
              };
              template_params = mkOption {
                type = types.attrs;
                default = {};
              };
            };

            config = mkIf (cfg.enable) {
              systemd.services.weirdfish-server = {
                wantedBy = [ "multi-user.target" ];
                after = [ "network.target" ];
                script =
                  let
                    params = (concatStrings (mapAttrsToList (k: v: "--template-key ${k} ${v} ") cfg.template_params));
                  in
                  ''
                    exec ${package}/bin/weirdfish-server --listen ${cfg.listen} --webroot ${cfg.webroot} ${params}
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
