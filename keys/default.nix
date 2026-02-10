{
  lib,
  ...
}:
with lib;

let
  g_PRIVILEGED = "privileged";
  g_WG = "wg";
  g_CRZ = "crz";
  groupnames = [ g_PRIVILEGED g_WG g_CRZ ];

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

  host_defs = [
    (mkPrivilegedHost "airberry"    ["host" "dcurgz"])
    (mkPrivilegedHost "blueberry"   ["host" "root" "dcurgz"])
    (mkPrivilegedHost "hyperberry"  ["host" "root" "dcurgz"])
    (mkSpecialKey "swiss")

    (mkGroupHost "miniberry"  ["host" "dcurgz"]    [g_WG])
    (mkGroupHost "piberry"    ["host" "piberry"]   [g_WG])
    (mkGroupHost "tauberry"   ["host" "tauberry"]  [g_WG])
    (mkGroupHost "fooberry"   ["host" "root"]      [g_CRZ])
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

#  ssh = {
#    groups = rec {
#      dcurgz.paths = [ 
#        ./ssh/airberry/host_ed25519.pub
#        ./ssh/airberry/dcurgz_ed25519.pub
#        ./ssh/hyperberry/host_ed25519.pub
#        ./ssh/hyperberry/root_ed25519.pub
#        ./ssh/hyperberry/dcurgz_ed25519.pub
#        ./ssh/blueberry/host_ed25519.pub
#        ./ssh/blueberry/root_ed25519.pub
#        ./ssh/blueberry/dcurgz_ed25519.pub
#        ./ssh/swiss/id_ed25519.pub
#      ];
#      dcurgz.keys = (mkListFromPaths dcurgz.paths);
#
#      wg.paths = [
#        ./ssh/miniberry/dcurgz_ed25519.pub
#        ./ssh/miniberry/host_ed25519.pub
#        ./ssh/piberry/piberry_ed25519.pub
#        ./ssh/piberry/host_ed25519.pub
#        ./ssh/tauberry/tauberry_ed25519.pub
#        ./ssh/tauberry/host_ed25519.pub
#      ];
#      wg.keys = (mkListFromPaths wg.paths);
#
#      privileged.paths = dcurgz.paths;
#      privileged.keys = (mkListFromPaths privileged.paths);
#    };
#
#    hosts = rec {
#      airberry.paths = [
#        ./ssh/airberry/dcurgz_ed25519.pub
#        ./ssh/airberry/host_ed25519.pub
#      ];
#      airberry.keys = (mkListFromPaths airberry.paths);
#
#      hyperberry.paths = [
#        ./ssh/hyperberry/dcurgz_ed25519.pub
#        ./ssh/hyperberry/root_ed25519.pub
#        ./ssh/hyperberry/host_ed25519.pub
#      ];
#      hyperberry.keys = (mkListFromPaths hyperberry.paths);
#
#      blueberry.paths = [
#        ./ssh/blueberry/dcurgz_ed25519.pub
#        ./ssh/blueberry/root_ed25519.pub
#        ./ssh/blueberry/host_ed25519.pub
#      ];
#      blueberry.keys = (mkListFromPaths blueberry.paths);
#
#      miniberry.paths = [
#        ./ssh/miniberry/dcurgz_ed25519.pub
#        ./ssh/miniberry/host_ed25519.pub
#      ];
#      miniberry.keys = (mkListFromPaths miniberry.paths);
#
#      piberry.paths = [
#        ./ssh/piberry/piberry_ed25519.pub
#        ./ssh/piberry/host_ed25519.pub
#      ];
#      piberry.keys = (mkListFromPaths piberry.paths);
#
#      tauberry.paths = [
#        ./ssh/tauberry/tauberry_ed25519.pub
#        ./ssh/tauberry/host_ed25519.pub
#      ];
#      tauberry.keys = (mkListFromPaths tauberry.paths);
#
#      fooberry.paths = [
#        ./ssh/fooberry/root_ed25519.pub
#        ./ssh/fooberry/host_ed25519.pub
#      ];
#      fooberry.keys = (mkListFromPaths fooberry.paths);
#    };
#
#    knownHosts = {
#      "airberry".publicKey = (builtins.readFile ./ssh/airberry/host_ed25519.pub);
#      "blueberry".publicKey = (builtins.readFile ./ssh/blueberry/host_ed25519.pub);
#      "hyperberry".publicKey = (builtins.readFile ./ssh/hyperberry/host_ed25519.pub);
#      "miniberry".publicKey = (builtins.readFile ./ssh/miniberry/host_ed25519.pub);
#      "piberry".publicKey = (builtins.readFile ./ssh/piberry/host_ed25519.pub);
#      "tauberry".publicKey = (builtins.readFile ./ssh/tauberry/host_ed25519.pub);
#      "fooberry".publicKey = (builtins.readFile ./ssh/fooberry/host_ed25519.pub);
#    };
#  };
#
#  hasGpg ={
#    groups = rec {
#      dcurgz.paths = [
#        ./gpg/dcurgz.asc
#        ./gpg/airberry.asc
#        ./gpg/blueberry.asc
#        ./gpg/hyperberry.asc
#        ./gpg/swiss.asc
#      ];
#      dcurgz.keys = (mkListFromPaths dcurgz.paths);
#
#      wg.paths = [
#        ./gpg/miniberry.asc
#        ./gpg/piberry.asc
#      ];
#      wg.keys = (mkListFromPaths wg.paths);
#
#      privileged.paths = dcurgz;
#      privileged.keys = (mkListFromPaths privileged.paths);
#    };
#
#    airberry.paths = [ ./gpg/airberry.asc ];
#    airberry.keys = (mkListFromPaths airberry.paths);
#    hyperberry.paths = [ ./gpg/hyperberry.asc ];
#    hyperberry.keys = (mkListFromPaths hyperberry.paths);
#    blueberry.paths = [ ./gpg/blueberry.asc ];
#    blueberry.keys = (mkListFromPaths blueberry.paths);
#    miniberry.paths = [ ./gpg/miniberry.asc ];
#    miniberry.keys = (mkListFromPaths miniberry.paths);
#    piberry.paths = [ ./gpg/piberry.asc ];
#    piberry.keys = (mkListFromPaths piberry.paths);
#  };
}
