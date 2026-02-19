{
  lib,
  ...
}:

{
# hostid needs to be fetched before installing
# ssh into machine and run hostid
  networking.hostId = "8425e349";

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            esp-stage0 = {
              size = "5G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
              };
            };
            root = {
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
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "true";
        };
        options.ashift = "12";
        datasets =
          let
            mkEncrypted = mountpoint: {
              type = "zfs_fs";
              options = {
                encryption = "aes-256-gcm";
                compression = "lz4";
                keyformat = "passphrase";
                mountpoint = "${mountpoint}";
              };
              mountpoint = "${mountpoint}";
            };
            mkVolume = mountpoint: {
              type = "zfs_fs";
              options.mountpoint = "${mountpoint}";
              mountpoint = "${mountpoint}";
            };
          in	
          {
            "encrypted" = mkEncrypted "/";
            "encrypted/home"  = mkVolume "/home";
            "encrypted/media" = mkVolume "/media";
            "encrypted/nix"   = mkVolume "/nix";
            "encrypted/opt"   = mkVolume "/opt";
            "encrypted/var"   = mkVolume "/var";
            "plain/media" = mkVolume "/media.unenc";
          };
      };
    };
  };

  boot.zfs.forceImportRoot = true;
  boot.zfs.devNodes = "/dev/disk/by-path";

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };
}
