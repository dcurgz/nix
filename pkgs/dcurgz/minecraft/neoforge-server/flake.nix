{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages.neoforge-1-21-1 = pkgs.callPackage ./. { };
        nixosModules.default = ({ config, pkgs, lib, ... }:
          with lib;

          let
            cfg = config.minecraft.neoforge;
          in
          {
            options.minecraft.neoforge = {
              enable = mkEnableOption "Enable the neoforge systemd service.";
              package = mkOption {
                type = types.package;
                description = "The neoforge server package to use.";
              };
              overlays = {
                modpack = mkOption {
                  type = types.path;
                  description = "A modpack overlay, given as a pkgs.linkFarm derivation.";
                };
                config = mkOption {
                  type = types.path;
                  description = "A config overlay, given as a pkgs.linkFarm derivation.";
                };
              };
              dataDir = mkOption {
                type = types.path;
                description = ''
                  The server directory is implemented as an overlayfs mount.
                  The data directory will serve as the upper dir, where runtime
                  files are stored.
                  '';
              };
            };

            config = mkIf (cfg.enable) (
              let
                homeDir = "/var/lib/minecraft";  
                modpackDir = pkgs.linkFarm "modpack-overlay" [
                  {
                    name = "mods";
                    path = cfg.overlays.modpack;
                  }
                ];
                configDir = cfg.overlays.config;
              in
              {
                users = {
                  users.minecraft = {
                    description = "Minecraft server";
                    home = "${homeDir}";
                    createHome = true;
                    homeMode = "770";
                    isSystemUser = true;
                    group = "minecraft";
                  };
                  groups.minecraft = { };
                };

                systemd.services.neoforge-server = {
                  wantedBy = [ "multi-user.target" ];
                  after = [ "network.target" ];
                  serviceConfig = {
                    Restart = "always";
                    RestartSec = "5s";
                    WorkingDirectory = "${homeDir}";
                  };
                  path = with pkgs; [ bash mount jre_headless ];
                  script =
                    let
                      mountDir = "${homeDir}/server.0";
                      serverDir = "${cfg.dataDir}/server";
                      workDir = "${cfg.dataDir}/.overlayfs";
                    in
                    ''
                    #!/usr/bin/env bash
                    set -xe
                    if [ ! -d "${mountDir}" ]; then
                      mkdir -p "${mountDir}"
                    fi
                    if [ ! -d "${cfg.dataDir}" ]; then
                      mkdir -vp "${cfg.dataDir}"
                    fi
                    if [ ! -d "${serverDir}" ]; then
                      mkdir -vp "${serverDir}"
                    fi
                    if [ -d "${workDir}" ]; then
                      rm -rf "${workDir}"
                    fi
                    mkdir -vp "${workDir}"
                    # Configure overlayfs mount
                    mount -t overlay overlay -o lowerdir="${cfg.package}":"${modpackDir}:${configDir}",upperdir="${serverDir}",workdir="${workDir}",userxattr ${mountDir}
                    # Start the server
                    cd "${mountDir}"
                    ./run.sh
                  '';
                };
              });
            }
        );
      }
    );
}
