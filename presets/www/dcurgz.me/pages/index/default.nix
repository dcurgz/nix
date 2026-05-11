{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (pkgs.by.lib) replaceOptionalVars;
  lib' = pkgs.callPackage ../lib { };
  templates = pkgs.callPackage ../templates { };
in
{
  config.by.www."dcurgz.me".pages = [
    {
      title = "DCURGZ.ME";
      slug = "index.html";
      src = lib.pipe ./index.7 [
        (path: replaceOptionalVars path templates)
        (path: lib'.renderMdoc "index.html" path)
      ];
    }
  ];
}
