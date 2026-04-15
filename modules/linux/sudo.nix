{
  inputs,
  ...
}:

{
  flake.modules.nixos.linux-sudo = 
    {
      lib,
      config,
      ...
    }:

    {
       # Enable sudo.
       security.sudo = {
         enable = true;
         # TODO: use some kind of auth for this
         wheelNeedsPassword = false;
       };
    };
}
