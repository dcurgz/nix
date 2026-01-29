{
  config,
  ...
}:

let
  hostname = config.networking.hostName;
in
{
  programs.git.enable = true;
  programs.git.config = {
    user.email = "${hostname}@curz.sh";
    user.name = "Dylan Curzon";
  };
}
