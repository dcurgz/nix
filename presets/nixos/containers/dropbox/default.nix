{
  config,
  lib,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) NIXOS_PRESETS;
in
{
  containers.dropbox = {
    autoStart = true;

    bindMounts."/root/Dropbox" = {
      hostPath = "/data/dropbox";
      isReadOnly = false;
    };

    config =
      {
        config,
        lib,
        ...
      }:
 
      {
        imports = [
          "${NIXOS_PRESETS}/misc/nix-daemon.nix"
          "${NIXOS_PRESETS}/packages/core"
        ];

        environment.systemPackages = with pkgs; [
          dropbox-cli
        ];

        networking.firewall = {
          allowedTCPPorts = [ 17500 ];
          allowedUDPPorts = [ 17500 ];
        };

        users.users.root.linger = true;
        systemd.user.services.dropbox = {
          description = "Dropbox";
          enable = true;
          wantedBy = [ "default.target" ];
          environment = {
            QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
            QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
          };
          serviceConfig = {
            ExecStart = "${lib.getBin pkgs.dropbox}/bin/dropbox";
            ExecReload = "${lib.getBin pkgs.coreutils}/bin/kill -HUP $MAINPID";
            KillMode = "control-group"; # upstream recommends process
            Restart = "on-failure";
            PrivateTmp = true;
            ProtectSystem = "full";
            Nice = 10;
          };
        };

        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
        ];

        system.stateVersion = "24.11";
      };
  };
}
