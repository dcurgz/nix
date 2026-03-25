{
  self,
  lib,
  inputs,
  ...
}:

{
  post, # A rendered mdoc file 
}:

let
  inherit (inputs.nix-html.lib) makePage;

  gitrev =
    toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");

  left = {
    span = {
      "@class" = "side-column";
      _fragment = [
        {
          div = {
            "@class" = "column-block";
            _fragment = [
              {
                div = {
                  "@class" = "list-heading";
                  _text = "? meta posts";
                };
              }
              {
                ul = [
                  {
                    li = {
                      a = {
                        "@href" = "/posts/why.html";
                        _text = "meta:why";
                      };
                    };
                  } 
                ];
              }
            ];
          };
        }
      ];
    };
  };
  middle = {
    span = {
      "@class" = "main-column";
      _fragment = [
        {
