{ config, pkgs, ... }:

{
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    set -gx EDITOR vim

    alias ga='git add'
    alias gaa='git add -A'
    alias gc='git commit'
    alias gcam='git commit --amend'
    alias gd="git diff HEAD"
    alias gl='git log --oneline'
    alias gp='git push'
    alias gs='git status'
    alias gst='git status'

    # prevent accidental overwrite
    alias mv='mv -i'
    alias rm='rm -i'

    # modern utils
    alias cat='bat -p'
    alias df='dust'
    alias diff='delta'
    alias l='exa -l'
    alias ls='exa'

    # Nix configuration
    alias nix='nix --extra-experimental-features "nix-command flakes"'
  '';
}
