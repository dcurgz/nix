let
  keys = (import ../keys { });

  # User keys
  privileged_keys = (builtins.map builtins.readFile keys.ssh.groups.privileged);

  # Shared keys
  wg_keys = (builtins.map builtins.readFile keys.ssh.groups.wg);

  fooberry = (builtins.map builtins.readFile keys.ssh.hosts.fooberry);
in
{
  "fooberry/cloudflare-key.age".publicKeys = privileged_keys ++ fooberry;
  "fooberry/Wi-Fi.age".publicKeys = privileged_keys ++ fooberry;
  "piberry/cloudflare-key.age".publicKeys = privileged_keys ++ wg_keys;
  "backup/restic-password.age".publicKeys = privileged_keys;
  "backup/restic-envvars.age".publicKeys = privileged_keys;
}
