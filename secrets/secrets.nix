let
  keys = (import ../keys { });

  # User keys
  privileged_keys = (builtins.map builtins.readFile keys.ssh.groups.privileged);

  # Shared keys
  wg_keys = (builtins.map builtins.readFile keys.ssh.groups.wg);
in
{
  "piberry/cloudflare-key.age".publicKeys = privileged_keys ++ wg_keys;
}
