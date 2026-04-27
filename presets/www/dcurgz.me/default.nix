{
  self,
  inputs,
  lib,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  inherit (pkgs) stdenv;
  inherit (inputs) nix-time;

  inherit (pkgs.by.lib) replaceOptionalVars;

  # mandoc escapes HTML in its '-T html' output mode. This reverses it.
  unescapeHtml = ''
    perl -pe 's{__RAW(.*?)__END}{
      my $s=$1;
      $s=~s/&amp;/&/g;
      $s=~s/&gt;/>/g;
      $s=~s/&lt;/</g;
      $s=~s/&quot;/"/g;
      $s }ge' \
  '';
  # __PREPROCESS(command)...__END blocks will invoke `command`, pass the block
  # contents into stdin, and replace the whole block with the command output.
  preprocessHtml = ''
    perl -0777 -MIPC::Open2 -pe 's{__PREPROCESS\((.*?)\)(.*?)__END} {
      my ($cmd, $block) = ($1, $2);
      $block=~s/&amp;/&/g;
      $block=~s/&gt;/>/g;
      $block=~s/&lt;/</g;
      $block=~s/&quot;/"/g;
      my $pid = open2(my $out, my $in, $cmd);
      print $in $block;
      close $in;
      local $/;
      my $result = <$out>;
      waitpid $pid, 0;
      $result }gse' \
  '';

  renderMdoc = path: lib.pipe path [
    # 1. pre-processing
    (path: replaceOptionalVars path {
      # preset for rendering code-blocks with chroma
      chroma = "chroma --html --html-only --html-prevent-surrounding-pre --html-lines";
    })
    # 2. render with mandoc and unescape
    (path: stdenv.mkDerivation (
      let
        name  = builtins.baseNameOf path;
        name' = lib.replaceString ".7" ".html" name;
      in
      {
        inherit name;
        nativeBuildInputs = with pkgs; [ mandoc perl chroma ];
        src = builtins.dirOf path;
        # Render a .7 mdoc source file into HTML, unescape, pre-process, then
        # write to output file.
        buildPhase = ''
          mandoc -T html -O style=/style.css "$src/${name}" \
            | ${unescapeHtml} \
            | ${preprocessHtml} \
            > ${name'} 
        '';
        # Copy into the out directory.
        installPhase = ''
          cp ./${name'} "$out"
        '';
      }))
    # 3. post-processing
    (path: replaceOptionalVars path {
      nix-gitrev =
        toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");
      nix-rfc822 = nix-time.lib.RFC-822 "GMT" self.lastModified;
      nix-date =
        with nix-time.lib.splitSecondsSinceEpoch {} self.lastModified;
        let
          month = toString B;
          day   = toString d;
          year  = toString Y;
        in
          "${month} ${day}, ${year}";
      color-scheme = builtins.readFile ./color-scheme.html;
    })
  ];

  webroot = (pkgs.linkFarm "webroot" [
    # TODO: Define this programmatically.
    {
      name = "index.html";
      path = renderMdoc ./index.7;
    }
    {
      name = "posts/index.html";
      path = renderMdoc ./posts/index.7;
    }
    {
      name = "posts/001_NixOS.html";
      path = renderMdoc ./posts/001_NixOS.7;
    }
    {
      name = "style.css";
      path = (stdenv.mkDerivation {
        name = "compiled-styles";
        src = ./.;
        buildPhase = ''
          cat *.css > ./output.css
        '';
        installPhase = ''
          cp ./output.css $out
        '';
      });
    }
    {
      name = "rss.xml";
      path = (pkgs.replaceVars ./rss.xml {
        nix-rfc822 = nix-time.lib.RFC-822 "GMT" self.lastModified;
      });
    }]);
in
{
  config.by.www."dcurgz.me".webroot = webroot;
}
