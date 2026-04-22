{
  inputs,
  config,
  ...
}:

{
  flake.modules.generic.__flake-default = [ ];
  flake.modules.nixos.__flake-default = [ ];
  flake.modules.darwin.__flake-default = [ ];
}
