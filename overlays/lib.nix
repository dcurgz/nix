{
  inputs,
  ...
} @args:

let
  lib = inputs.nixpkgs.lib;
in
# TODO: use infuse
_final: prev: {
  by = {
    lib = {
      replaceOptionalVars = src: replacements:
      (let
        subst-var-by = name: value: [
            # We use --subst-var-by instead of --replace-fail to prevent errors.
            "--subst-var-by"
            (lib.escapeShellArg "${name}")
            (lib.escapeShellArg (lib.trivial.defaultTo "${name}" value))
          ];
          substitutions = lib.lists.concatLists (lib.mapAttrsToList subst-var-by replacements);
      in
      prev.stdenvNoCC.mkDerivation {
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
      });

      # TODO - this doesn't work and kaida is working on a solution.
      replaceOptionalVarsWithFiles = name: src: files: prev.runCommand name
        {
          nativeBuildInputs = with prev; [ jq ];
        }
        ''
          NAMES_JSON="${builtins.toJSON (builtins.attrNames files)}"
          PATHS_JSON="${builtins.toJSON (builtins.attrValues files)}"

          mkdir -p $out
          OUT=$out/debug

          echo $NAMES_JSON >> $OUT
          echo $PATHS_JSON >> $OUT

          readarray -t NAMES < <(echo $NAMES_JSON | jq -c '.[]')
          readarray -t PATHS < <(echo $PATHS_JSON | jq -c '.[]')

          touch $OUT
          echo "this is a test" > $OUT
          
          for X in $NAMES; do
            echo $X >> $OUT
          done

          for X in $PATHS; do
            echo $X >> $OUT
          done
        '';

      strings.startsWith = prefix: str:
        let
          substr = builtins.substring 0 (builtins.stringLength prefix) str;
        in
          prefix == substr;
    };
  };
}
