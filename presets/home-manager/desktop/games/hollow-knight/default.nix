{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [ lumafly ];
}
