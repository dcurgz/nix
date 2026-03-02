{ pkgs, ... }:

{
  programs.vim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs; [
      vimPlugins.vim-nix
      vimPlugins.rainbow
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
      nmap <C-s> :w<CR>
      imap <C-S> <Esc>:w<CR>a
    '';
  };
}
