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
      # [ [ flake.modules.<class>, flake.modules.<class> ] ]
      (builtins.mapAttrs (_k: v: v))
      # [ flake.modules.<class>, flake.modules.<class> ]
      (builtins.flatten)
      # [ [ flake.modules.<class>.<aspect>, flake.modules.<class>.<aspect> ] ]
      (builtins.mapAttrs (_k: v: v))
      # [ flake.modules.<class>.<aspect>, flake.modules.<class>.<aspect> ]
      (builtins.flatten)
      # filter: any aspect that has a tag inside useTags
      (builtins.filter (aspect: builtins.any (t: lib.lists.elem t useTags)))
    ];

    # helpers for specific classes
    generic.mkAspect =
      tags: flake.lib.mkAspect { class = "generic"; inherit tags; }; 
    nixos.mkAspect =
      tags: flake.lib.mkAspect { class = "nixos"; inherit tags; }; 
    darwin.mkAspect =
      tags: flake.lib.mkAspect { class = "darwin"; inherit tags; }; 
    home-manager.mkAspect =
      tags: flake.lib.mkAspect { class = "home-manager"; inherit tags; }; 

    mkNixOS =
      {
        system,
        aspects,
        modules ? [ ],
        specialArgs ? { },
      } @args:

      (let
        _ = assert builtins.all (a: a._type == "aspect") -> throw "aspects must all have 'aspect' type"; "";
        aspects = lib.lists.flatten aspects;
        nixosAspects = builtins.filter (a: a.class == "nixos") aspects;
      in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system; 
          modules = modules ++ (builtins.map (aspect: aspect._module) nixosAspects);
          specialArgs = specialArgs // { _classArgs = args; };
        });
  }; 
}
