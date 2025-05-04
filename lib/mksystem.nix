{
  inputs,
  nixpkgs,
}:
{
  ...
}@args:
let
  lib = nixpkgs.lib;
  ctx = import ./mkcontext.nix { inherit lib args; };
  builder = {
    darwin = inputs.nix-darwin.lib.darwinSystem;
    linux = nixpkgs.lib.nixosSystem;
  };
in
builder.${ctx.os} {
  inherit (ctx) system;

  specialArgs = { inherit ctx inputs; };
  modules = lib.lists.flatten [
    ../configuration.nix
    (lib.optionals ctx.isDarwin [
      inputs.nix-homebrew.darwinModules.nix-homebrew
      inputs.home-manager.darwinModules.home-manager
    ])
    (lib.optionals ctx.isLinux [
      inputs.home-manager.nixosModules.home-manager
    ])
    {
      home-manager.extraSpecialArgs = { inherit ctx; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${ctx.user} = ../users/${ctx.user};
    }
    ../profiles/${ctx.profile}
    ../hosts/${ctx.host}
  ];
}
