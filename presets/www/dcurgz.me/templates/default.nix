{
  lib,
  ...
}:

let
  template = path: (lib.pipe path [
    builtins.readFile
    (lib.removeSuffix "\n")
  ]);
in
{
  # mandoc
  back = template ./back.7;
  build-time = template ./build-time.7;
  contact = template ./contact.7;
  header = template ./header.7;
}
