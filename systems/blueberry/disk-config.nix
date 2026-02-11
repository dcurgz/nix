{
  lib,
  ...
}:

let
  keys_mountpoint = "/keys";
in
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
                mountpoint = "/boot.unenc";
                mountOptions = [ "umask=0077" ];
              };
            };
	    # keys to unlock the stage1 esp partition, and some partitions in the zfs pool
	    keys = {
	      size = "128M";
	      content = {
	        type = "luks";
	        type = "filesystem";
		format = "vfat";
		mountpoint = "${keys_mountpoint}";
		mountOptions = [ "umask=0077" ];
	      };
	    };
            esp-stage1 = {
              size = "5G";
	      content = {
	        type = "luks";
                extraOpenArgs = [ ];
                settings = {
                  allowDiscards = true;
		  keyFile = "/keys/esp-stage1.key";
	        };
                content = {
	          type = "EF00";
	          content = {
	            type = "filesystem";
	            format = "vfat";
	            mountpoint = "/boot";
	            mountOptions = [ "umask=0077" ];
	          };
                };
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
		pool = "zpool";
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
	datasets = {
	  "zroot-enc" = {
	    type = "zfs_fs";
	    options = {
	      encryption = "aes-256-gcm";
	      compression = "lz4";
	      keyformat = "passphrase";
	      keylocation = "file:///${keys_mountpoint}/zpool-enc.key";
	    };
	  };
	  "zpool-enc/nix" = {
	    type = "zfs_fs";
	    options = {
	      mountpoint = "/nix";
	    };
	    mountpoint = "/nix";
	  };
	  "zpool-enc/home" = {
	    type = "zfs_fs";
	    options = {
	      mountpoint = "/home";
	    };
	    mountpoint = "/home";
	  };
	  "zpool-enc/media" = {
	    type = "zfs_fs";
	    options = {
	      mountpoint = "/media";
	    };
	    mountpoint = "/media";
	  };
	  # leave an unencrypted partition for performance reasons.
	  "zroot-unenc" = {
	    type = "zfs_fs";
	  };
	  "zpool-unenc/media.unenc" = {
	    type = "zfs_fs";
	    options.mountpoint = "/media.unenc";
	    mountpoint = "/media.unenc";
	  };
	};
      };
    };
  };

  boot.initrd = {
    supportedFileSystems.ext4 = true;
    luks.devices.keys = {
      yubikey = {
      	slot = 2;
	twoFactor = false;
	storage.device = "/dev/disk/by-partlabel/disk-main-esp-stage0";
      };
      postOpenCommands = ''
        mkdir -p ${keys_mountpoint}
	mount -t ext4 -o /dev/mapper/keys ${keys_mountpoint} || (dmesg && exit 1)
	zpool import -f -a
	zfs load-key -a
	unmount ${keys_mountpoint}
      '';
    };
  };

  boot.zfs.forceImportRoot = true;
  boot.zfs.devNodes = "/dev/disk/by-path";

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
  };
}
