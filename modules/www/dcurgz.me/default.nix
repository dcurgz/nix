{
  lib,
  ...
}:
with lib;

{
  options.by.www."dcurgz.me" = {
    webroot = mkOption {
      type = types.path;
      description = "The webroot for this internet resource.";
    };
  };
}
