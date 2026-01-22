{ pkgs, ... }:

{ 
  home.packages = with pkgs; [
    way-displays
  ];

  home.file = {
    ".config/way-displays/cfg.yaml".source = ./cfg.yaml;
  };
}
