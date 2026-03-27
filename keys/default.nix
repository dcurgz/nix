{
  lib,
  ...
}:
with lib;

let
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

    (mkGroupHost "miniberry"  ["host" "dcurgz"]    [g_WG])
    (mkGroupHost "piberry"    ["host" "piberry"]   [g_WG])
    (mkGroupHost "tauberry"   ["host" "tauberry"]  [g_WG])
    (mkGroupHost "fooberry"   ["host" "root"]      [g_CRZ])

    (mkGroupHost "publicproxy"   ["host"]      [g_EXT])

    (mkGuest "vm-jellyfin")
    (mkGuest "vm-vikunja")
    (mkGuest "vm-immich")
    (mkGuest "vm-teamspeak")
    (mkGuest "vm-openwebui")
    (mkGuest "vm-mc-slime")
    (mkGuest "vm-mc-slime-sta")
    (mkGuest "vm-mc-wg-0")
    (mkGuest "vm-mc-wg-1")
    (mkGuest "vm-mc-leedlemon")
  ];
in
{
  ssh = {
    # An attrset of groups, mapped to an attrset of {paths, keys}.
    groups = listToAttrs (builtins.map (groupname: {
      name = groupname;
      value = rec {
        paths =
          let
            filtered = (builtins.filter (host: (builtins.elem groupname host.groups)) host_defs);
          in
            flatten (builtins.map (host: (builtins.map (user: ./. + "/ssh/${host.hostname}/${user}_ed25519.pub") host.names)) filtered);
        keys = (mkListFromPaths paths);
      };
    }) groupnames);

    # An attrset of hosts, mapped to an attrset of {paths, keys}.
    hosts = listToAttrs (builtins.map (host: {
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
      listToAttrs (builtins.map (host: {
        name = host.hostname;
        value = {
          publicKeyFile = (./. + "/ssh/${host.hostname}/host_ed25519.pub");
        };
      }) filtered);
    };

  gpg = {
    groups = listToAttrs (builtins.map (groupname: {
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

    hosts = listToAttrs (builtins.map (host: {
      name = host.hostname;
      value = rec {
        paths = [ ( ./. + "/gpg/${host.hostname}" ) ];
        keys = (mkListFromPaths paths);
      };
    }) host_defs);
  };
}
