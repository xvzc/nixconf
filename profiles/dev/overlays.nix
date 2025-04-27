{
  ctx,
  lib,
  inputs,
  ...
}:
# ┌──────────────┐
# │ DEV overlays │
# └──────────────┘
lib.lists.flatten [
  # ┌─────────────────┐
  # │ overlays.common │
  # └─────────────────┘
  (final: prev: {
    gh = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.gh;
    neovim = inputs.neovim-nightly.packages.${prev.system}.default;
    wezterm = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.wezterm;
    alacritty = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.alacritty;
    nanum-square-neo = final.callPackage ../../pkgs/nanum-square-neo.nix { };
  })

  # ┌─────────────────┐
  # │ overlays.darwin │
  # └─────────────────┘
  (lib.optionals ctx.isDarwin [
    (final: prev: {
      yabai = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.yabai;
      skhd = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.skhd;

      # Since `_1password-gui` for Darwin is marked as broken, we replace
      # this with a dummy data so that we can keep  `_1password-gui` as a
      # shared package. On macOS instead, 1Password will be installed via
      # Homebrew. See also https://github.com/NixOS/nixpkgs/issues/254944
      _1password-gui = final.stdenv.mkDerivation {
        pname = "_1password-gui";
        version = "0.0.0";
        src = null;
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
        '';
      };

      # Due to some issues with `wezterm` on Darwin,
      # we replace it with an empty package. It will 
      # be installed via Homebrew instead.
      wezterm = final.stdenv.mkDerivation {
        pname = "wezterm";
        version = "0.0.0";
        src = null;
        dontUnpack = true;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
        '';
      };
    })
  ])

  # ┌────────────────┐
  # │ overlays.linux │
  # └────────────────┘
  (lib.optionals ctx.isLinux [
    (final: prev: {
      # Empty
    })
  ])
]
