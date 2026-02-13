{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs; [
      vimPlugins.vim-nix
      vimPlugins.rainbow
      vimPlugins.nvim-lspconfig
    ];

    extraConfig = ''
      let maplocalleader = ","
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set encoding=utf-8

      filetype plugin on

      let g:rainbow_active = 1

      if executable('rust-analyzer')
      au User lsp_setup call lsp#register_server({
        \ 'name': 'rust-analyzer',
        \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rust-analyzer']},
        \ 'allowlist': ['rust'],
        \ })
      endif

      " https://github.com/joongwon/home.nix/blob/d72f5ce2d8ae60a8254af32bd7989155ef6159cf/modules/common.nix#L46
      function! s:enable_fold() abort
      setlocal foldmethod=expr
      setlocal foldexpr=lsp#ui#vim#folding#foldexpr()
      setlocal foldtext=lsp#ui#vim#folding#foldtext()
      endfunction
      function! s:disable_fold() abort
      setlocal foldmethod=manual
      setlocal foldtext=foldtext()
      setlocal foldexpr=0
      endfunction
      command! LspEnableFold call s:enable_fold()
      command! LspDisableFold call s:disable_fold()
      function! s:on_lsp_buffer_enabled() abort
      setlocal signcolumn=yes
      if exists('+tagfunc')
        setlocal tagfunc=lsp#tagfunc
      endif
      nmap <buffer> gd <plug>(lsp-definition)
      nmap <buffer> gi <plug>(lsp-implementation)
      nmap <buffer> <leader>rn <plug>(lsp-rename)
      nmap <buffer> [d <plug>(lsp-previous-diagnostic)
      nmap <buffer> ]d <plug>(lsp-next-diagnostic)
      nmap <buffer> K <plug>(lsp-hover)
      nmap <buffer> <leader>ca <plug>(lsp-code-action)
      nnoremap <buffer> <expr><c-j> lsp#scroll(+4)
      nnoremap <buffer> <expr><c-k> lsp#scroll(-4)
      let g:lsp_format_sync_timeout = 1000
      endfunction
      augroup lsp_install
      au!
      autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
      augroup END
      let g:lsp_diagnostics_virtual_text_prefix = " ‣ "

      " Ctrl+S saves to file.
      nmap <C-s> :w<CR>
      imap <C-S> <Esc>:w<CR>a
    '';
  };
}
