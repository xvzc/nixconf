{
  ctx,
  lib,
  inputs,
  ...
}:
{
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.overlays = lib.lists.flatten [
    (import ./profiles/${ctx.profile}/overlays.nix { inherit ctx lib inputs; })
    (import ./hosts/${ctx.host}/overlays.nix { inherit ctx lib inputs; })
    (import ./users/${ctx.user}/overlays.nix { inherit ctx lib inputs; })
  ];
}
