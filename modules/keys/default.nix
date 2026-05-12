{
  inputs,
  ...
} @args:

let
  inherit (inputs.nixpkgs) lib;
  inherit (args.config) flake;

  g_PRIVILEGED = "privileged";
  g_WG = "wg";
  g_CRZ = "crz";
  g_EXT = "ext";
  groupnames = [ g_PRIVILEGED g_WG g_CRZ g_EXT ];

  mkListFromPaths = paths: (builtins.map builtins.readFile paths);
  mkDefaultHost = hostname: names: {
    inherit hostname names;
    groups = [ ];
    isHost = true;
    hasGpg = true;
  };
  mkPrivilegedHost = hostname: names: {
    inherit hostname names;
    groups = [ g_PRIVILEGED ];
    isHost = true;
    hasGpg = true;
  };
  mkGroupHost = hostname: names: groups: {
    inherit hostname names groups;
    isHost = true;
    hasGpg = false;
  };
  mkSpecialKey = keyname: {
    hostname = keyname;
    names = [ "id" ];
    groups = [ g_PRIVILEGED ];
    isHost = false;
    hasGpg = true;
  };
  mkGuest = hostname: {
    inherit hostname;
    names = [ "host" ];
    groups = [ g_EXT ];
    isHost = true;
  };

  host_defs = [
    (mkPrivilegedHost "airberry"    ["host" "dcurgz"])
    (mkPrivilegedHost "blueberry"   ["host" "root" "dcurgz"])
    (mkPrivilegedHost "hyperberry"  ["host" "root" "dcurgz"])
    (mkSpecialKey "swiss")
    (mkSpecialKey "blueberry-nt")

    (mkGroupHost "miniberry"  ["host" "dcurgz"]    [g_WG])
    (mkGroupHost "piberry"    ["host" "piberry"]   [g_WG])
    (mkGroupHost "tauberry"   ["host" "tauberry"]  [g_WG])
    (mkGroupHost "fooberry"   ["host" "root"]      [g_CRZ])

    (mkGroupHost "publicproxy"   ["host"]      [g_EXT])

    (mkGuest "vm-claude")
    (mkGuest "vm-immich")
    (mkGuest "vm-jellyfin")
    (mkGuest "vm-mc-leedl-sta")
    (mkGuest "vm-mc-leedlemon")
    (mkGuest "vm-mc-slime-0")
    (mkGuest "vm-mc-slime-1")
    (mkGuest "vm-mc-wg-0")
    (mkGuest "vm-mc-wg-1")
    (mkGuest "vm-openwebui")
    (mkGuest "vm-teamspeak")
    (mkGuest "vm-trilium")
    (mkGuest "vm-vikunja")
    (mkGuest "vx-jupiter")
  ];

  options = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };
  keys = {
    ssh = {
      # An attrset of groups, mapped to an attrset of {paths, keys}.
      groups = lib.listToAttrs (builtins.map (groupname: {
        name = groupname;
        value = rec {
          paths =
            let
              filtered = (builtins.filter (host: (builtins.elem groupname host.groups)) host_defs);
            in
              lib.flatten (builtins.map (host: (builtins.map (user: ./. + "/ssh/${host.hostname}/${user}_ed25519.pub") host.names)) filtered);
          keys = (mkListFromPaths paths);
        };
      }) groupnames);

      # An attrset of hosts, mapped to an attrset of {paths, keys}.
      hosts = lib.listToAttrs (builtins.map (host: {
        name = host.hostname;
        value = rec {
          paths = (builtins.map (user: ./. + "/ssh/${host.hostname}/${user}_ed25519.pub") host.names);
          keys = (mkListFromPaths paths);
        };
      }) host_defs);

      # An attrset of hosts, mapped to an attrset of {paths, keys}. 
      # The paths and keys lists contain exclusively host keys.
      knownHosts =
        let
          filtered = (builtins.filter (host: host.isHost) host_defs);
        in
        lib.listToAttrs (builtins.map (host: {
          name = host.hostname;
          value = {
            publicKeyFile = (./. + "/ssh/${host.hostname}/host_ed25519.pub");
          };
        }) filtered);
      };

    gpg = {
      groups = lib.listToAttrs (builtins.map (groupname: {
        name = groupname;
        value = rec {
          paths =
            let
              filtered = (builtins.filter (host: host.hasGpg && (builtins.elem groupname host.groups)));
            in
              (builtins.map (host: ./. + "/gpg/${host.hostname}.asc") filtered);
          keys = (mkListFromPaths paths);
        };
      }) groupnames);

      hosts = lib.listToAttrs (builtins.map (host: {
        name = host.hostname;
        value = rec {
          paths = [ ( ./. + "/gpg/${host.hostname}" ) ];
          keys = (mkListFromPaths paths);
        };
      }) host_defs);
    };
  };

  mkModule = class: flake.lib.${class}.mkAspect (with flake.tags; [ flake-default ])
    (_args: {
      config.by.keys = keys;
    });
in
{
  config.by.keys = keys;
  config.flake.flakeModules.berry-keys = keys;
  config.flake.modules.generic.keys = mkModule "generic";
  config.flake.modules.nixos.keys = mkModule "nixos";
  config.flake.modules.darwin.keys = mkModule "darwin";
  config.flake.modules.home-manager.keys = mkModule "home-manager";
}
