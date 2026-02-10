let
  inputs = (import ../. { }).inputs;
  inherit (inputs.nixpkgs) lib;
  keys = (import ../keys { inherit lib; });

  withDefault = k: (k ++ [ keys.groups.privileged.keys ]);
in
with keys.groups;
with keys.hosts;

{
  # Tailscale
  "tailscale/hyperberry.age".publicKeys    = privileged.keys;
  # hyperberry
  "backup/restic-password.age".publicKeys  = (withDefault hyperberry.keys);
  "backup/restic-envvars.age".publicKeys   = (withDefault hyperberry.keys);
  # fooberry
  "fooberry/cloudflare-key.age".publicKeys = (withDefault fooberry.keys);
  "fooberry/Wi-Fi.age".publicKeys          = (withDefault fooberry.keys);
  # piberry
  "piberry/cloudflare-key.age".publicKeys  = (withDefault wg.keys);
}
