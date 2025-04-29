{ inputs, nixpkgs }:
{
  system,
  profile,
  machine,
  username,
  hostname,
  ...
}:
let
  lib = nixpkgs.lib;
  systemAttr = lib.findFirst (attr: builtins.elem system attr.forSystems) null [
    {
      type = "darwin";
      builder = inputs.nix-darwin.lib.darwinSystem;
      forSystems = lib.platforms.darwin;
    }
    {
      type = "linux";
      builder = lib.nixosSystem;
      forSystems = lib.platforms.linux;
    }
  ];

  ctx = {
    inherit machine username hostname;
    isDarwin = builtins.elem system lib.platforms.darwin;
    isLinux = builtins.elem system lib.platforms.linux;
  };
in
systemAttr.builder {
  inherit system;

  modules = lib.lists.flatten [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;

      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;
      nixpkgs.overlays = lib.lists.flatten [
        (import ../profiles/${profile}/overlays.nix { inherit ctx lib inputs; })
        (import ../machines/${machine}/overlays.nix { inherit ctx lib inputs; })
      ];
    }
    (lib.optionals ctx.isDarwin [
      inputs.nix-homebrew.darwinModules.nix-homebrew
      inputs.home-manager.darwinModules.home-manager
    ])
    (lib.optionals ctx.isLinux [
      inputs.home-manager.nixosModules.home-manager
    ])
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = ../profiles/${profile}/home/${systemAttr.type}.nix;
      home-manager.extraSpecialArgs = { inherit ctx; };
    }
    ../profiles/${profile}/system/${systemAttr.type}.nix
    ../machines/${machine}
  ];

  specialArgs = { inherit ctx inputs; };
}
