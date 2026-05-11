{
  self,
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (pkgs.by.lib) replaceOptionalVars;
  lib' = pkgs.callPackage ../../../lib { inherit self inputs; };
  templates = pkgs.callPackage ../../../templates { };
  code = rec {
    fibonacci-pseudocode = ''
      fib(0) = 0
      fib(1) = 1
      fib(2) = fib(n-1) + fib(n-2)
    '';
    fibonacci-c = lib'.renderCode "c" ./fibonacci.c;
    fibonacci-c' = pkgs.stdenv.mkDerivation "fibonacci-c" {
      src = ./fibonacci.c;
      nativeBuildInputs = with pkgs; [ gcc ];
      buildPhase = ''
        gcc $src -o fibonacci
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp -v ./fibonacci $out/bin
      '';
    };
    fibonacci-input = 23;
    fibonacci-c-output =
      let
        result = pkgs.runCommand "fibonacci-c-output" {}
          ''
            ${lib.getExe fibonacci-c'} ${fibonacci-input}
          '';
      in
        lib'.renderCode "bash" ''
          $ gcc fibonacci.c -o fibonacci
          $ ./fibonacci ${fibonacci-input}
          $ # ==> ${result}
        '';
    fibonacci-hs = lib'.renderCode "haskell" ./fibonacci.hs;
    fibonacci-hs' = pkgs.stdenv.mkDerivation "fibonacci-hs" {
      src = ./fibonacci.hs;
      nativeBuildInputs = with pkgs; [ ghc ];
      buildPhase = ''
        ghc $src -o fibonacci
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp -v ./fibonacci $out/bin
      '';
    };
    fibonacci-hs-output =
      let
        result = pkgs.runCommand "fibonacci-hs-output" {}
          ''
            ${lib.getExe fibonacci-hs'} ${fibonacci-input}
          '';
      in
        lib'.renderCode "bash" ''
          $ ghc fibonacci.hs -o fibonacci
          $ ./fibonacci ${fibonacci-input}
          $ # ==> ${result}
        '';
  };
in
{
  config.by.www."dcurgz.me".pages = [
    {
      title = "DCURGZ.ME";
      slug = "posts/001-NixOS.html";
      src = lib.pipe ./001-NixOS.7 [
        (path: replaceOptionalVars path templates)
        (path: replaceOptionalVars path code)
        (path: lib'.renderMdoc "001-NixOS.html" path)
      ];
    }
  ];
}
