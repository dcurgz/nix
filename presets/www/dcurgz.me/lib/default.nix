{
  self,
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (pkgs.by.lib) replaceOptionalVars;
  inherit (inputs) nix-time;

  # mandoc escapes HTML in its '-T html' output mode. This reverses it.
  unescapeHtml = ''
    perl -0777 -pe 's{__HTML(.*?)__ENDHTML}{
      my $s=$1;
      $s=~s/&amp;/&/g;
      $s=~s/&gt;/>/g;
      $s=~s/&lt;/</g;
      $s=~s/&quot;/"/g;
      $s }gse' \
  '';
in
{
  renderMdoc = name: path: lib.pipe path [
    ### (1.) render mdoc(7) to html.
    (path: pkgs.stdenv.mkDerivation (
      let
        #name  = builtins.baseNameOf path;
        #name' = lib.replaceString ".7" ".html" name;
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
        # Render a .7 mdoc source file into HTML, then unescape __HTML blocks.
        buildPhase = ''
          cat "$src/${path}" \
            | mandoc -T html -O style=/style.css \
            | ${unescapeHtml} \
            > ${name} 
        '';
        # Copy into the out directory.
        installPhase = ''
          cp ./${name} "$out"
        '';
      }))
    ### (2.) replace common variables in the output HTML.
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
      color-scheme = builtins.readFile ../resources/color-scheme.html;
    })
  ];

  renderCode = name: lang: path: builtins.readFile (pkgs.runCommand name
    {
      nativeBuildInputs = with pkgs; [ chroma ];
    }
    ''
      echo "${path}" \
        | chroma -l "${lang}" --html --html-only --html-lines --html-prevent-surrounding-pre
    '');
}
