{
  ctx,
  lib,
  inputs,
  ...
}@args:
# ┌──────────────────┐
# │ DEFAULT OVERLAYS │
# └──────────────────┘
lib.lists.flatten [
  (final: prev: {
    gh = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.gh;
    neovim = inputs.neovim-nightly.packages.${prev.system}.default;
    wezterm = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.wezterm;
  })

  # ┌─────────────────────────────────────────────────────────┐
  # │ Import profile- and machine-specific overlays if exists │
  # └─────────────────────────────────────────────────────────┘
  (import ./profiles/${ctx.profile}/overlays.nix args)
  (import ./machines/${ctx.machine}/overlays.nix args)
]
