{
  lib,
  inputs,
  outputs,
  builder,
  extraModules,
}:
{
  user,
  host,
  system,
  ...
}:
let
  ctx = {
    inherit user host system;
  };
in
builder {
  inherit (ctx) system;

  specialArgs = { inherit ctx inputs outputs; };
  modules = lib.lists.flatten [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;
    }
    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        outputs.overlays.additions
        outputs.overlays.overrides
        outputs.overlays.nixpkgs-unstable
      ];
    }
    extraModules
    ../hosts/${ctx.host}
    {
      home-manager.extraSpecialArgs = { inherit ctx inputs outputs; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${ctx.user} = ../users/${ctx.user}.nix;
    }
  ];
}
