{
  ctx,
  lib,
  inputs,
  ...
}@args:
lib.lists.flatten [
  (import ./profiles/${ctx.profile}/overlays.nix args)
  (import ./machines/${ctx.machine}/overlays.nix args)
]
