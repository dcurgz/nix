{
  inputs,
  config,
  ...
}:

{
  # Modules will add themselves to flake-default's imports list.
  flake.modules.generic.flake-default = { };
  flake.modules.generic.flake-default' =
    {
      ...
    }:

    config.flake.modules.generic.flake-default;
}
