{
  inputs,
  config,
  prebuiltPackages,
  ...
}:

{
  perSystem =
    {
      system,
      ...
    }:

    let
      pkgs = prebuiltPackages.${system};
      json = builtins.toJSON config.flake.metadata;
    in
    {
      packages.mkflakegraph = builtins.break pkgs.stdenv.mkDerivation {
        src = ./.;
      };
    };
}
