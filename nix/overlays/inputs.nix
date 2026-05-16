{
  inputs,
  ...
} @args:

pkgs': pkgs: {
  inherit (inputs.nfsm.packages.${pkgs.system}) nfsm nfsm-cli;
  isd       = inputs.isd.packages.${pkgs.system}.default;
  deploy-rs = inputs.deploy-rs.packages.${pkgs.system}.default or null;
  agenix    = inputs.agenix.packages.${pkgs.system}.default;
  dankMaterialShell = inputs.dankMaterialShell.packages.${pkgs.system}.default;
  niri      = inputs.niri.packages.${pkgs.system}.niri-unstable;
  awww      = inputs.awww.packages.${pkgs.system}.awww;
}
