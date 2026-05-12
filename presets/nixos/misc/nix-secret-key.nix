{
  config,
  ...
} @args:
let
  inherit (args.globals) FLAKE_ROOT;
in
{
  age.secrets.nix-signing-secret-key = {
    file = "${FLAKE_ROOT}/secrets/nix/berry-privileged.age";
  };
  nix.settings.secret-key-files = [ config.age.secrets.nix-signing-secret-key.path ];
}
