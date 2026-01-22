{
  ...
}:

{
  by.portmap = {
    internal = 
      let 
        __base = 8090;
      in
      {
        # Note, leave gaps to allow for multiple instances.
        anubis = __base + 1;
        nginx  = __base + 5;
        weirdfish = __base + 9;
      };
  };
}
