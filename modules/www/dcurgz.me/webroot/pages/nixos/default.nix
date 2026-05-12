{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos."dcurgz.me-001-NixOS" = flake.lib.nixos.mkAspect (with flake.tags; [ flake-default ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    let
      inherit (pkgs.by.lib) replaceOptionalVars;
      cfg = config.by.www."dcurgz.me";
      inherit (cfg) templates;
      lib' = cfg.lib;

      fibonacci-c' = pkgs.stdenv.mkDerivation {
        name = "fibonacci-c-bin";
        src = ./fibonacci.c;
        dontUnpack = true;
        nativeBuildInputs = with pkgs; [ gcc ];
        buildPhase = ''
          gcc $src -o fibonacci
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp -v ./fibonacci $out/bin
        '';
        meta.mainProgram = "fibonacci";
      };
      fibonacci-hs' = pkgs.stdenv.mkDerivation {
        name = "fibonacci-hs-bin";
        src = ./fibonacci.hs;
        dontUnpack = true;
        nativeBuildInputs = with pkgs; [ ghc ];
        buildPhase = ''
          ghc $src -o fibonacci
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp -v ./fibonacci $out/bin
        '';
        meta.mainProgram = "fibonacci";
      };

      code = rec {
        fibonacci-pseudocode = ''
          fib(0) = 0
          fib(1) = 1
          fib(2) = fib(n-1) + fib(n-2)
        '';
        fibonacci-c = lib'.renderCode {
          name = "fibonacci-c";
          lang = "c";
          path = ./fibonacci.c;
        };
        fibonacci-input = "23";
        fibonacci-c-output =
          let
            result = pkgs.runCommand "fibonacci-c-output" {}
              ''
                ${lib.getExe fibonacci-c'} ${fibonacci-input} > "$out"
              '';
          in
          lib'.renderCode {
            name = "fibonacci-c-output";
            lang = "bash";
            path = pkgs.writeText "fibonacci-c-output-text" ''
              $ gcc fibonacci.c -o fibonacci
              $ ./fibonacci ${fibonacci-input}
              $ # ==> ${builtins.readFile result}
            '';
          };
        fibonacci-hs = lib'.renderCode {
          name = "fibonacci-hs";
          lang = "haskell";
          path = ./fibonacci.hs;
        };
        fibonacci-hs-output =
          let
            result = pkgs.runCommand "fibonacci-hs-output" {}
              ''
                ${lib.getExe fibonacci-hs'} ${fibonacci-input} > "$out"
              '';
          in
          lib'.renderCode {
            name = "fibonacci-hs-output";
            lang = "bash";
            path = pkgs.writeText "fibonacci-hs-output-text" ''
              $ ghc fibonacci.hs -o fibonacci
              $ ./fibonacci ${fibonacci-input}
              $ # ==> ${builtins.readFile result}
            '';
          };
      };
    in
    {
      config.by.www."dcurgz.me".pages = [
        {
          title = "My NixOS config (WIP!)";
          description = "How I'm using Nix today";
          date = "2026-05-12";
          slug = "posts/001-NixOS.html";
          src = lib.pipe ./001-NixOS.7 [
            (path: replaceOptionalVars path templates)
            (path: replaceOptionalVars path code)
            (path: lib'.renderMdoc "001-NixOS.html" path)
          ];
        }
      ];
    });
}
