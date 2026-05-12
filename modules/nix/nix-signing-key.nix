{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (args.globals) FLAKE_ROOT;
in
{
  flake.modules.nixos.nix-signing-key = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-privileged ])
    ({
      config,
      ...
    }:

    {
      age.secrets.nix-signing-secret-key = {
        file = "${FLAKE_ROOT}/agenix-secrets/agenix/nix/berry-privileged.age";
      };
      nix.settings.secret-key-files = [ config.age.secrets.nix-signing-secret-key.path ];
    });

  flake.modules.darwin.nix-signing-key = flake.lib.darwin.mkAspect (with flake.tags; [ darwin-privileged ])
    ({
      config,
      ...
    }:
    
    {
      age.secrets.nix-signing-secret-key = {
        file = "${FLAKE_ROOT}/agenix-secrets/agenix/nix/berry-privileged.age";
      };
      nix.settings.secret-key-files = [ config.age.secrets.nix-signing-secret-key.path ];
    });
}
