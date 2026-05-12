{
  inputs,
  ...
}:

{
  flake.modules.nixos.weirdfish-cax11-4gb-disk =
    {
      lib,
      ...
    }:

    {
      imports = [
        inputs.disko.nixosModules.default
      ];

      networking.hostId = "007f0101";

      disko.devices = {
        disk = {
          vda = {
            type = "disk";
            device = "/dev/sda";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                zfs = {
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = "zroot";
                  };
                };
              };
            };
          };
        };
        zpool = {
          zroot = {
            type = "zpool";
            mode = "";
            options = {
              ashift = "12";
              autotrim = "on";
              autoexpand = "on";
              cachefile = "none";
            };
            rootFsOptions = {
              compression = "zstd";
              mountpoint = "none";
              atime = "off";
              xattr = "sa";
              canmount = "off";
              devices = "off";
            };
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";
            datasets = {
              root = {
                type = "zfs_fs";
                mountpoint = "/";
              };
              nix = {
                type = "zfs_fs";
                mountpoint = "/nix";
              };
              media = {
                type = "zfs_fs";
                mountpoint = "/media";
              };
              var = {
                type = "zfs_fs";
                mountpoint = "/var";
              };
              home = {
                type = "zfs_fs";
                mountpoint = "/home";
              };
            };
          };
        };
      };

      boot.zfs.forceImportRoot = true;
      boot.zfs.devNodes = "/dev/disk/by-path";
    };
}
