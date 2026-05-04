{
  lib,
  pkgs,
  ...
}:

{
  # pages = [{
  #   title = str,
  #   slug = str,
  #   listed = bool,
  #   src = derivation,
  # }]
  mkWebroot = pages:
    let
      files = map (p: {
        name = p.slug;
        path = p.src;
      }) pages;
    in
      (pkgs.linkFarm "webroot" files);
}
