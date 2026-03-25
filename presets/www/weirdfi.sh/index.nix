{
  self,
  lib,
  inputs,
  ...
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
          div = {
            "@class" = "column-block";
            _text = ''
              You have arrived at weirdfi.sh.
              
              This website is currently under construction. Expect various nonsense supported by cute things.
              '';
          };
        }
        {
          div =
            let
              nixconfig-link = "https://github.com/dcurgz/nix/blob/master/presets/www/weirdfi.sh/index.nix";
              nix-html-link = "https://github.com/NotAShelf/niXhtml";
            in
              {
                "@class" = "column-block";
                _text = ''
                  This website is built declaratively using NixOS: <a href="${nixconfig-link}">dcurgz/nix</a>.
                  <br><br>
                  It uses NotAShelf's <a href="${nix-html-link}">HTML DSL for Nix</a> because I've gone completely insane, and so far nobody has stopped me.
                  <br>
                  <p style="float: right;">${gitrev}</p>
                '';
              };
        }
      ];
    };
  };
  right = {
    span = {
      "@class" = "side-column";
      _fragment = [
      ];
    };
  };

  body = {
    _fragment = [
      {
        div = {
          "@class" = "colour-palette";
          # Use _raw to prevent whitespace insertion.
          _raw = lib.strings.concatStrings [
            ''<span class="colour-box colour-box-1"></span>''
            ''<span class="colour-box colour-box-2"></span>''
            ''<span class="colour-box colour-box-3"></span>''
            ''<span class="colour-box colour-box-4"></span>''
            ''<span class="colour-box colour-box-5"></span>''
          ];
        };
      }
      {
        div = {
          "@class" = "super-container";
          _fragment = [
            left
            middle
            right
          ];
        };
      }
    ];
  };
in
  makePage {
    title = "weirdfi.sh";
    lang = "en";
    doctype = "html5";
    stylesheets = [ "/style.css" ];
    inherit body;
  }

