{
  description = "NixOS configuration as a flake";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    dankMaterialShell.inputs.dgop.follows = "dgop";
    dankMaterialShell.inputs.nixpkgs.follows = "nixpkgs";
    dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:dcurgz/deploy-rs/dcurgz/add-skip-offline";
    dgop.inputs.nixpkgs.follows = "nixpkgs";
    dgop.url = "github:AvengeMedia/dgop";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko/latest";
    flake-compat.flake = false;
    flake-compat.url = "github:NixOS/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    isd.url = "github:kainctl/isd"; # systemd tui
    maccel.url = "github:Gnarus-G/maccel"; # mouse acceleration kernel driver
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    naersk.url = "github:nix-community/naersk";
    neoforge-1-21-1.inputs.nixpkgs.follows = "nixpkgs";
    neoforge-1-21-1.url = "path:./pkgs/neoforge-1-21-1";
    nfsm.inputs.nixpkgs.follows = "nixpkgs";
    nfsm.url = "github:gvolpe/nfsm";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:sodiboo/niri-flake";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-html.url = "github:NotAShelf/niXhtml";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-rosetta-builder.inputs.nixpkgs.follows = "nixpkgs";
    nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
    nix-time.url = "path:./pkgs/flockenzeit";
    nixgl.url = "github:nix-community/nixGL";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nurpkgs.inputs.nixpkgs.follows = "nixpkgs";
    nurpkgs.url = "github:nix-community/NUR"; # Nix user repository
    weirdfish-server.inputs.nixpkgs.follows = "nixpkgs";
    weirdfish-server.url = "path:./pkgs/weirdfish-server";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs:
    let
      inherit (inputs.nixpkgs) lib;
      globals = {
        FLAKE_ROOT = ./.;
      };
    in
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          inherit globals;
          pkgs = (import inputs.nixpkgs {
            config.allowUnfree = true;
          });
        };
      }
      {
        systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
        imports = (inputs.import-tree.withLib lib).leafs ./modules;
      };
}
