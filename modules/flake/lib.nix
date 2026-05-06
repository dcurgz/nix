{
  inputs,
  lib,
  globals,
  config,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  inherit (config) flake;
in
{
  # Define options to merge downstream flake lib contributions.
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
  };

  config.flake.lib = {
    #mkNixOS = args: inputs.nixpkgs.lib.nixosSystem args;
    #mkDarwin = args: inputs.nix-darwin.lib.darwinSystem args;

    mkTag = tagName: {
      _type = "tag";
      name = tagName;
    };

    mkAspect =
      {
        class,
        tags ? [],
      } @args:
      
      (module: (args // { _type = "aspect"; _module = module; }));

    use = useTags: lib.pipe flake.modules [
      (builtins.attrValues)
      (builtins.map builtins.attrValues)
      (lib.lists.flatten)
      (builtins.filter (v: (v ? _type) && (v._type == "aspect")))
      (builtins.filter (v: builtins.any (t: lib.lists.elem t useTags) v.tags))
    ];

    # helpers for specific classes
    generic.mkAspect =
      tags: (flake.lib.mkAspect { class = "generic"; inherit tags; }); 
    nixos.mkAspect =
      tags: (flake.lib.mkAspect { class = "nixos"; inherit tags; }); 
    darwin.mkAspect =
      tags: (flake.lib.mkAspect { class = "darwin"; inherit tags; }); 
    home-manager.mkAspect =
      tags: (flake.lib.mkAspect { class = "home-manager"; inherit tags; }); 

    mkNixOS =
      {
        system,
        modules,
        specialArgs ? { },
      } @args:

      let
        flat = lib.lists.flatten modules;
        aspects = builtins.filter (a: builtins.isAttrs a && a ? "_type" && a._type == "aspect") flat;
        nixosAspects = builtins.filter (a: a.class == "nixos") aspects;
        nixosModules = lib.lists.subtractLists aspects flat;
      in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = nixosModules ++ (builtins.map (aspect: aspect._module) nixosAspects);
          specialArgs = specialArgs // { _classArgs = args; };
        };
  }; 
}
