{
  description = "NixOS configuration as a flake";

  inputs = {
    # https://github.com/gvolpe/nfsm/pull/3/changes/211eb44e77ce0b6e10f32b15f78f8aee5340fcbd
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
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    isd.url = "github:kainctl/isd"; # systemd tui
    maccel.url = "github:Gnarus-G/maccel"; # mouse acceleration kernel driver
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    naersk.url = "github:nix-community/naersk";
    nfsm.inputs.nixpkgs.follows = "nixpkgs";
    nfsm.url = "github:gvolpe/nfsm?rev=211eb44e77ce0b6e10f32b15f78f8aee5340fcbd";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:sodiboo/niri-flake";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-rosetta-builder.inputs.nixpkgs.follows = "nixpkgs";
    nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
    nixgl.url = "github:nix-community/nixGL";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    nixpkgs-immich.url = "github:nixos/nixpkgs?rev=0fd2db475afdde93c9e4b1625aafb8eb41b99807";
    nixpkgs-ollama.url = "github:nixos/nixpkgs?rev=9d29d5f667d7467f98efc31881e824fa586c927e";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nurpkgs.inputs.nixpkgs.follows = "nixpkgs";
    nurpkgs.url = "github:nix-community/NUR"; # Nix user repository

    ## local flakes
    mandoc-forked.url = "path:./vendor/mandoc";
    neoforge-1-21-1.inputs.nixpkgs.follows = "nixpkgs";
    neoforge-1-21-1.url = "path:./vendor/neoforge-1-21-1";
    nix-time.url = "path:./vendor/flockenzeit";
    weirdfish-server.inputs.nixpkgs.follows = "nixpkgs";
    weirdfish-server.url = "path:./vendor/weirdfish-server";

    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    let
      inherit (inputs.nixpkgs) lib;
      globals = {
        FLAKE_ROOT = ./.;
      };
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      prebuiltPackages =
        let
          mkPkgs = system: (import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;
            overlays = import ./overlays {
              inherit inputs globals;
              inherit (inputs.nixpkgs) lib;
            } ++ [ inputs.nurpkgs.overlays.default ];
          });
          attrsList = builtins.map (system: {
            name = system;
            value = mkPkgs system;
          }) systems;
          attrs = builtins.listToAttrs attrsList;
        in
          attrs;
    in
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          inherit globals prebuiltPackages;
        };
      }
      {
        inherit systems;
        imports = (inputs.import-tree.withLib lib).leafs ./modules;

        perSystem = { system, ... }:
          let
            pkgs = prebuiltPackages.${system};
          in
          {
            packages.weirdfish-server = pkgs.by.weirdfish-server;
            packages.neoforge-1-21-1  = pkgs.by.neoforge-1-21-1;
          };
      };
}
