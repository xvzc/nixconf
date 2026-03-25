# Original src: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{ inputs, pkgs, ... }:
{
  # ┌─────────────────┐
  # │ GLOBAL OVERLAYS │
  # └─────────────────┘
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
    (final: prev: {
      unstable =
        let
          unstablePatched = pkgs.applyPatches {
            name = "unstable";
            src = inputs.nixpkgs-unstable;
            patches = [
              # Add patches here
              # ./patches/direnv-502769.patch
            ];
          };
        in
        import unstablePatched {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
    })
  ];
}
