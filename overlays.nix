# Original src: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{ inputs, ... }:
{
  # ┌─────────────────┐ 
  # │ GLOBAL OVERLAYS │ 
  # └─────────────────┘ 
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.system;
        config.allowUnfree = true;
      };

      neovim-nightly = inputs.neovim-nightly.packages.${prev.system}.default;
    })
  ];
}
