{
  inputs,
  ...
}:

{
  flake.modules.generic.constants =
    {
      lib,
      ...
    }:

    {
      options.by.constants = lib.mkOption {
        type = lib.types.unspecified;
        default = { };
      };

      options.by.secrets = lib.mkOption {
        type = lib.types.unspecified;
        default = { };
      };
    };
}
