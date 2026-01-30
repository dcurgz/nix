{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.by.programs.prism-launcher;
in
{
  options.by.programs.prism-launcher = {
    enable = mkEnableOption "Enable the PrismLauncher pack generation.";
    shareDirectory = {
      user = mkOption {
        description = ''
          The user that should own the generated pack directories.
        '';
        type = types.str;
      };
      group = mkOption {
        description = ''
          The group that should own the generated pack directories.
        '';
        type = types.str;
      };
      path = mkOption {
        description = ''
          The absolute path to the share directory for PrismLauncher.
        '';
        type = types.str;
      };
    };

    packs = mkOption {
      type = types.attrsOf (types.submodule ({ config, name, ... }: {
        options = {
          instanceConfig = mkOption {
            description = ''
              An attrset of options that will bootstrap the instance.cfg file for the Prism Launcher pack.
            '';
            type = types.attrs;
            default = {
              name = "declarative-pack";
              AutomaticJava = true;
              MaxMemAlloc = 4096;
              MinMemAlloc = 512;
              OverrideMemory = true;
            };
          };
          components = mkOption {
            description = ''
              A list of attrsets that will form the mmc-pack.json file for the Prism Launcher pack.
            '';
            type = types.listOf types.attrs;
            default = [];
          };
          modpack = mkOption {
            description = ''
              A path to a directory of mods for the Prism Launcher pack.
            '';
            type = types.nullOr types.path;
            default = null;
          };
        };
      }));
      default = [];
    };
  };

  config = (
    let
      toml = (pkgs.formats.toml { });
      json = (pkgs.formats.json { });
      instances-ro = pkgs.linkFarm "instances-ro" (lists.flatten (mapAttrsToList (name: pack: ([
        {
          name = "${name}/instance.cfg";
          path = (toml.generate "${name}-instance.cfg" pack.instanceConfig);
        }
        {
          name = "${name}/mmc-pack.json";
          path = (json.generate "${name}-mmc-pack.json" {
            components = pack.components;
          });
        }
      ] ++ (optionals (pack.modpack != null) [{
        name = "${name}/minecraft/mods";
        path = pack.modpack;
      }]))) cfg.packs));
    in
    {
      systemd.tmpfiles.rules =
        let
          inherit (cfg.shareDirectory) user group;
        in
        [
          "L+ ${cfg.shareDirectory.path}/.instances_ro 0740 ${user} ${group} - ${instances-ro}"
        ];

      systemd.services.mount-prismlauncher-instances = {
        enable = true;
        description = "Configure an overlayfs mount for Nix-managed PrismLauncher packs.";
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [ mount umount ];
        serviceConfig = 
          let
            inherit (cfg.shareDirectory) path user group;

            lowerdir = instances-ro;
            upperdir = "${path}/.instances-overlay";
            workdir  = "${path}/.instances-tmpdir";
            mount    = "${path}/instances";
          in
          {
            ExecStart = pkgs.writeShellScript "mount-prism-launcher-instances" ''
              #!/usr/bin/env bash
              if [ ! -z "$( ls -A '${mount}' )" ]; then
                mv -v "${mount}" "${cfg.shareDirectory.path}/instances.bak"
              fi
              mkdir -v "${mount}"
              mkdir -v "${upperdir}"
              mkdir -v "${workdir}"
              umount "${mount}"
              mount -t overlay overlay -o lowerdir="${lowerdir}",upperdir="${upperdir}",workdir="${workdir}" "${mount}"
              chown -R ${user}:${group} "${mount}"
            '';
          };
      };
    });
}
