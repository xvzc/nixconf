{
  lib,
  ctx,
  inputs,
  ...
}:
[
  (final: prev: {
    neovim = inputs.neovim-nightly.packages.${prev.system}.default;
    nanum-square-neo = final.callPackage ../../pkgs/nanum-square-neo.nix { };
  })

  (lib.mkIf ctx.isDarwin (
    final: prev: {
      yabai = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.yabai;
      skhd = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.skhd;
    }
  ))
]
