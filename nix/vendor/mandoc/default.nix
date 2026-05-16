{
  pkgs ? import <nixpkgs>,
  ...
}:

pkgs.mandoc.overrideAttrs (final: prev:
  let
    decorate = ./decorate.patch;
  in
  {
    pname = "mandoc-fork";

    nativeBuildInputs = with pkgs; [ git ];
    preBuild = (prev.preBuild or "") + ''
              git apply ${decorate}
    '';
  })
