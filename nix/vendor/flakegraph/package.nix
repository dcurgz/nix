{
  lib,
  buildNpmPackage,
}:

buildNpmPackage {
  name = "flakegraph";
  src = ./.;
  npmDepsHash = "sha256-jk22ZyPk6tlfQLp/st1Lz0WIq5vEJLn5stS2xlU1ZfA=";
  dontNpmBuild = true;
}
