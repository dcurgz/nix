let
  inherit (import ../.) inputs;
  inherit (inputs.nixpkgs) lib;
  flake = import ../.;
  keys  = flake.outputs.flakeModules.berry-keys;
  withDefault = k: (k ++ keys.ssh.groups.privileged.keys);
in
with keys.ssh.groups;
with keys.ssh.hosts;

{
  "agenix/nix/berry-privileged.age".publicKeys = keys.ssh.groups.privileged.keys;
  ### Wireguard
  "agenix/wireguard/001-key.age".publicKeys = (withDefault hyperberry.keys);
  ### Tailscale
  # hosts
  "agenix/tailscale/hosts/hyperberry.age".publicKeys   = (withDefault hyperberry.keys);
  "agenix/tailscale/hosts/blueberry.age".publicKeys    = (withDefault blueberry.keys);
  "agenix/tailscale/hosts/publicproxy.age".publicKeys  = (withDefault publicproxy.keys);
  "agenix/tailscale/hosts/piberry.age".publicKeys      = (withDefault piberry.keys);
  "agenix/tailscale/hosts/tauberry.age".publicKeys     = (withDefault tauberry.keys);
  # guests
  "agenix/tailscale/guests/vm-claude.age".publicKeys       = (withDefault vm-claude.keys);
  "agenix/tailscale/guests/vm-immich.age".publicKeys       = (withDefault vm-immich.keys);
  "agenix/tailscale/guests/vm-jellyfin.age".publicKeys     = (withDefault vm-jellyfin.keys);
  "agenix/tailscale/guests/vm-mc-leedl-sta.age".publicKeys = (withDefault vm-mc-leedl-sta.keys);
  "agenix/tailscale/guests/vm-mc-leedlemon.age".publicKeys = (withDefault vm-mc-leedlemon.keys);
  "agenix/tailscale/guests/vm-mc-wg-0.age".publicKeys      = (withDefault vm-mc-wg-0.keys);
  "agenix/tailscale/guests/vm-mc-wg-1.age".publicKeys      = (withDefault vm-mc-wg-1.keys);
  "agenix/tailscale/guests/vm-mc-slime-0.age".publicKeys   = (withDefault vm-mc-slime-0.keys);
  "agenix/tailscale/guests/vm-mc-slime-1.age".publicKeys   = (withDefault vm-mc-slime-1.keys);
  "agenix/tailscale/guests/vm-openwebui.age".publicKeys    = (withDefault vm-openwebui.keys);
  "agenix/tailscale/guests/vm-teamspeak.age".publicKeys    = (withDefault vm-teamspeak.keys);
  "agenix/tailscale/guests/vm-trilium.age".publicKeys      = (withDefault vm-trilium.keys);
  "agenix/tailscale/guests/vm-vikunja.age".publicKeys      = (withDefault vm-vikunja.keys);
  "agenix/tailscale/guests/vx-jupiter.age".publicKeys      = (withDefault vx-jupiter.keys);
  "agenix/tailscale/guests/vm-mb-build-aarch64.age".publicKeys = (withDefault vm-mb-build-aarch64.keys);
  # hyperberry
  "agenix/backup/restic-password.age".publicKeys     = (withDefault hyperberry.keys);
  "agenix/backup/restic-envvars.age".publicKeys      = (withDefault hyperberry.keys);
  # fooberry
  "agenix/fooberry/cloudflare-key.age".publicKeys    = (withDefault fooberry.keys);
  "agenix/fooberry/Wi-Fi.age".publicKeys             = (withDefault fooberry.keys);
  # piberry
  "agenix/piberry/cloudflare-key.age".publicKeys     = (withDefault wg.keys);
  # tauberry
  "agenix/tauberry/mopidy-conf.age".publicKeys       = (withDefault tauberry.keys);
  # wg
  "agenix/wg/Wi-Fi.age".publicKeys = (withDefault wg.keys);
}
