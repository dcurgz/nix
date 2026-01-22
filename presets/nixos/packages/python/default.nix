{
  pkgs,
  ...
}:

{
  # Make these packages available in every host, container and virtual machine.
  environment.systemPackages = with pkgs; [
    python313
    uv
  ];
}
