{
  ctx,
  lib,
  inputs,
  ...
}:
# ┌──────────────┐
# │ DEV OVERLAYS │
# └──────────────┘
lib.lists.flatten [
  # ┌────────┐
  # │ common │
  # └────────┘
  (final: prev: {
    alacritty = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.alacritty;
    # yabai = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.yabai;
    nanum-square-neo = final.callPackage ../../pkgs/nanum-square-neo.nix { };
  })

  # ┌────────┐
  # │ darwin │
  # └────────┘
  (lib.optionals ctx.isDarwin [
    (final: prev: {
      _1password-gui = final.callPackage ../../pkgs/_1password-gui.nix { };
    })
  ])

  # ┌───────┐
  # │ linux │
  # └───────┘
  (lib.optionals ctx.isLinux [
    (final: prev: {
      # Empty
    })
  ])
]
