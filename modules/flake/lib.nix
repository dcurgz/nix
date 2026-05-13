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

  # https://discourse.nixos.org/t/list-compare-diff-or-substraction/62367/5
  subtractLists = a: b: let
    foundIndex = lib.lists.findFirstIndex (x: x == lib.lists.head b) null a;
    length =  builtins.length a;
  in
    if a == [] then [] else
    if b == [] then a else
    if foundIndex == null then
      subtractLists a (lib.lists.tail b)
    else
      subtractLists (lib.lists.sublist 0 foundIndex a ++ lib.lists.sublist (foundIndex + 1) length a) (lib.lists.tail b);
in
{
  # Define options to merge downstream flake lib contributions.
  options.flake.lib = lib.mkOption { type = lib.types.attrsOf lib.types.unspecified; };

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

        uniqueAspects = lib.lists.unique nixosAspects;
        bad = subtractLists nixosAspects uniqueAspects;
      in
        assert (builtins.length bad == 0) || throw "the following aspect is included more than once: ${builtins.head bad}";
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = nixosModules ++ (builtins.map (aspect: aspect._module) nixosAspects);
          specialArgs = specialArgs // { _classArgs = args; };
        };

    mkDarwin =
      {
        system,
        modules,
        specialArgs ? { },
      } @args:

      let
        flat = lib.lists.flatten modules;
        aspects = builtins.filter (a: builtins.isAttrs a && a ? "_type" && a._type == "aspect") flat;
        darwinAspects = builtins.filter (a: a.class == "darwin") aspects;
        darwinModules = lib.lists.subtractLists aspects flat;

        uniqueAspects = lib.lists.unique darwinAspects;
        bad = subtractLists darwinAspects uniqueAspects;
      in
        assert (builtins.length bad == 0) || throw "the following aspect is included more than once: ${builtins.head bad}";
        inputs.nix-darwin.lib.darwinSystem {
          inherit system;
          modules = darwinModules ++ (builtins.map (aspect: aspect._module) darwinAspects);
          specialArgs = specialArgs // { _classArgs = args; };
        };
  }; 
}
