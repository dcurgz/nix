{
  pkgs,
  lib,
  ...
}:
with lib;

let
  inherit (pkgs) stdenvNoCC;
in
{
  # This is copied and tweaked from:
  # https://github.com/NixOS/nixpkgs/blob/0726f235730331846135184e71d1d1bc3a4b49ad/pkgs/build-support/replace-vars/replace-vars-with.nix
  replaceOptionalVars = src: replacements:
    let
      subst-var-by = name: value: [
        # We use --subst-var-by instead of --replace-fail to prevent errors.
        "--subst-var-by"
        (escapeShellArg "${name}")
        (escapeShellArg (defaultTo "${name}" value))
      ];
      substitutions = concatLists (mapAttrsToList subst-var-by replacements);
    in
    stdenvNoCC.mkDerivation {
      name = baseNameOf (toString src);
      doCheck = false;
      dontUnpack = true;
      preferLocalBuild = true;
      allowSubstitutes = false;

      buildPhase = ''
        runHook preBuild

        substitute "${src}" "$out" ${lib.concatStringsSep " " substitutions}

        runHook postBuild
      '';
    };
}
