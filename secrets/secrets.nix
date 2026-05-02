let
  inherit (import ../.) inputs;
  inherit (inputs.nixpkgs) lib;
  keys = (import ../keys { inherit lib; });

  withDefault = k: (k ++ keys.ssh.groups.privileged.keys);
in
with keys.ssh.groups;
with keys.ssh.hosts;

{
  ### Wireguard
  "wireguard/001-key.age".publicKeys = (withDefault hyperberry.keys);
  ### Tailscale
  # hosts
  "tailscale/hosts/hyperberry.age".publicKeys   = (withDefault hyperberry.keys);
  "tailscale/hosts/blueberry.age".publicKeys    = (withDefault blueberry.keys);
  "tailscale/hosts/publicproxy.age".publicKeys  = (withDefault publicproxy.keys);
  # guests
  "tailscale/guests/vm-claude.age".publicKeys       = (withDefault vm-claude.keys);
  "tailscale/guests/vm-immich.age".publicKeys       = (withDefault vm-immich.keys);
  "tailscale/guests/vm-jellyfin.age".publicKeys     = (withDefault vm-jellyfin.keys);
  "tailscale/guests/vm-mc-leedl-sta.age".publicKeys = (withDefault vm-mc-leedl-sta.keys);
  "tailscale/guests/vm-mc-leedlemon.age".publicKeys = (withDefault vm-mc-leedlemon.keys);
  "tailscale/guests/vm-mc-wg-0.age".publicKeys      = (withDefault vm-mc-wg-0.keys);
  "tailscale/guests/vm-mc-wg-1.age".publicKeys      = (withDefault vm-mc-wg-1.keys);
  "tailscale/guests/vm-mc-slime-0.age".publicKeys   = (withDefault vm-mc-slime-0.keys);
  "tailscale/guests/vm-mc-slime-1.age".publicKeys   = (withDefault vm-mc-slime-1.keys);
  "tailscale/guests/vm-openwebui.age".publicKeys    = (withDefault vm-openwebui.keys);
  "tailscale/guests/vm-teamspeak.age".publicKeys    = (withDefault vm-teamspeak.keys);
  "tailscale/guests/vm-trilium.age".publicKeys      = (withDefault vm-trilium.keys);
  "tailscale/guests/vm-vikunja.age".publicKeys      = (withDefault vm-vikunja.keys);
  "tailscale/guests/vx-jupiter.age".publicKeys      = (withDefault vx-jupiter.keys);
  # hyperberry
  "backup/restic-password.age".publicKeys     = (withDefault hyperberry.keys);
  "backup/restic-envvars.age".publicKeys      = (withDefault hyperberry.keys);
  # fooberry
  "fooberry/cloudflare-key.age".publicKeys    = (withDefault fooberry.keys);
  "fooberry/Wi-Fi.age".publicKeys             = (withDefault fooberry.keys);
  # piberry
  "piberry/cloudflare-key.age".publicKeys     = (withDefault wg.keys);
  # tauberry
  "tauberry/mopidy-conf.age".publicKeys       = (withDefault tauberry.keys);
  # wg
  "wg/Wi-Fi.age".publicKeys = (withDefault wg.keys);
}
