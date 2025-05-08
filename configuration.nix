{
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
    (final: prev: {
      neovim = inputs.neovim-nightly.packages.${prev.system}.default;
      nanum-square-neo = final.callPackage ./pkgs/nanum-square-neo.nix { };
      yabai = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.yabai;
      skhd = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.skhd;
    })
  ];
}
