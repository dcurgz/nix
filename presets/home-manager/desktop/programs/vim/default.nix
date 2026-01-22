{ pkgs, ... }:

{
  programs.vim.enable = true;
  programs.vim.plugins = with pkgs; [
    vimPlugins.vim-nix
    vimPlugins.rainbow
  ];
  programs.vim.extraConfig = ''
     let g:rainbow_active = 1

     " Ctrl+S saves to file.
     nmap <C-s> :w<CR>
     imap <C-S> <Esc>:w<CR>a
  '';
}
