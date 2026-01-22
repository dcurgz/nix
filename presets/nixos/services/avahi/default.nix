{
  ...
}:

{
  # Enable Avahi for network service discovery.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = false;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
