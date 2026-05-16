{
  inputs,
  lib,
  ...
} @args:
let
  inherit (args.config) flake;

  # handy lookup table for gen-z slang
  gen-z = {
    "brapet" = {
      definition = "bro carpet";
      description = "the carpet that you share with your bros";
    };
    "lokay" = {
      definition = "lowkey okay";
      description = "when it's lowkey okay";
    };
    "goonion" = {
      definition = "good opinion";
      description = "when it's a good opinion";
    };
    "quiche loreain" = {
      definition = "quirky niche lore explain";
      description = "when you explain the lore behind something that is quirky and niche";
    };
    "quiche peanemis" = {
      definition = "quirky niche peak cinema anaylsis";
      description = "when you explain something that's great which is quirky and niche";
    };
  };
in
{
  options.by.gen-z = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
  };

  config.by.gen-z = gen-z;
}
