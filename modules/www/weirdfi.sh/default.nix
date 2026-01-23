{
  lib,
  ...
}:
with lib;

{
  options.by.www."weirdfi.sh" = {
    webroot = mkOption {
      type = types.path;
      description = "The webroot for this internet resource.";
    };
  };
}
