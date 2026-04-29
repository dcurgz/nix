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
    perl -0777 -pe 's{__RAW(.*?)__END}{
      my $s=$1;
      $s=~s/&amp;/&/g;
      $s=~s/&gt;/>/g;
      $s=~s/&lt;/</g;
      $s=~s/&quot;/"/g;
      $s }gse' \
  '';
  # __PREPROCESS(command)...__END blocks will invoke `command`, pass the block
  # contents into stdin, and replace the whole block with the command output.
  # __PREPROCESS and __POSTPROCESS as equivalent, but one the former runs
  # before mandoc compilation, while the latter runs after compilation, on
  # HTML.
  transform = blockName: ''
    perl -0777 -MIPC::Open3 -pe 's{__${blockName}\((.*?)\)(.*?)__END} {
      my ($cmd, $block) = ($1, $2);
      for ($cmd, $block) {
        s/&amp;/&/g;
        s/&gt;/>/g;
        s/&lt;/</g;
        s/&quot;/"/g;
      }
      my $pid = open3(my $in, my $out, 0, "bash", "-c", $cmd);
      print $in $block;
      close $in;
      local $/;
      my $result = <$out>;
      waitpid $pid, 0;
      $result }gse' \
  '';
  renderMdoc = path: lib.pipe path [
    ### (1.) pre-mandoc; mdoc format.
    # replace templates first, which might require substitution themselves.
    (path: (replaceOptionalVars path
      (let
        readFileAndTrim = path: (lib.pipe path [
          builtins.readFile
          (lib.removeSuffix "\n")
        ]);
      in
      {
        # Templates
        "include:back"         = readFileAndTrim ./templates/back.7;
        "include:build-time"   = readFileAndTrim ./templates/build-time.7;
        "include:contact"      = readFileAndTrim ./templates/contact.7;
        "include:fibonacci.c"  = readFileAndTrim ./templates/fibonacci.c;
        "include:fibonacci.hs" = readFileAndTrim ./templates/fibonacci.hs;
        "include:header"       = readFileAndTrim ./templates/header.7;
      })))
    # now substitute mdoc vars.
    (path: replaceOptionalVars path {
      # Code-formatting command preset
      chroma = "chroma --html --html-only --html-lines --html-prevent-surrounding-pre";
    })
    ### (2.) render mdoc(7) to html.
    (path: stdenv.mkDerivation (
      let
        name  = builtins.baseNameOf path;
        name' = lib.replaceString ".7" ".html" name;
      in
      {
        inherit name;
        nativeBuildInputs = with pkgs; [
          inputs.mandoc-forked.packages.${pkgs.system}.default
          perl
          chroma
          gcc
          (haskellPackages.ghcWithPackages.override { } (
            p: with p; [ ghc-stdin ]
          ))
        ];
        src = builtins.dirOf path;
        # Render a .7 mdoc source file into HTML, unescape, pre-process, then
        # write to output file.
        buildPhase = ''
          cat "$src/${name}" \
            | ${transform "PREPROCESS"} \
            | mandoc -T html -O style=/style.css \
            | ${unescapeHtml} \
            | ${transform "POSTPROCESS"} \
            > ${name'} 
        '';
        # Copy into the out directory.
        installPhase = ''
          cp ./${name'} "$out"
        '';
      }))
    ### (3.) post-mandoc; html format.
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
