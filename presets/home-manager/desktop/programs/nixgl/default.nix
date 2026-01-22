{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixgl.nixGLMesa
  ];

  nixGL.defaultWrapper = "mesa";
}
