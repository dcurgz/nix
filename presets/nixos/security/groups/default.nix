{
  ...
}:

{
  users.groups = {
    media.gid = 3001;
    data.gid  = 3002;
    #keys.gid - keys are defined by NixOS as gid 96
  };
}
