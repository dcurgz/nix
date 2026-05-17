{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.home-manager.vim = flake.lib.home-manager.mkAspect (with flake.tags; [ nixos-base darwin-base ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      programs.vim = {
        enable = true;
        defaultEditor = true;

        plugins = with pkgs; [
          vimPlugins.vim-nix
          vimPlugins.rainbow
          vimPlugins.goyo-vim
          vimPlugins.ale
        ];

        extraConfig = ''
          let maplocalleader = ","
          set tabstop=4
          set shiftwidth=4
          set expandtab
          set encoding=utf-8
          set clipboard=unnamedplus

          filetype plugin on

          let g:rainbow_active = 1
          " Ctrl+S saves to file.
          nmap <C-S> :w<CR>
          imap <C-S> <Esc>:w<CR>
        '';
      };
    });
}
