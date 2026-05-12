{
  inputs,
  ...
} @args:

_final: prev: {
  inherit (inputs.nfsm.packages.${prev.system}) nfsm nfsm-cli;
  isd       = inputs.isd.packages.${prev.system}.default;
  deploy-rs = inputs.deploy-rs.packages.${prev.system}.default or null;
  agenix    = inputs.agenix.packages.${prev.system}.default;
  dankMaterialShell = inputs.dankMaterialShell.packages.${prev.system}.default;
  niri      = inputs.niri.packages.${prev.system}.niri-unstable;
}
