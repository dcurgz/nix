{
  ...
}:

{
  networking.wireless = {
    enable = true;
    userControlled = true;
  };
  services.matter-server = {
    enable = true;
    openFirewall = true;
    extraArgs = [
      "--primary-interface"
      "wlan0"
    ];
  };
}
