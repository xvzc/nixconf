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
      # Since `_1password-gui` for Darwin is marked as broken, we replace
      # this with a dummy data- so that we can keep `_1password-gui` as a
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

  # ┌───────┐
  # │ linux │
  # └───────┘
  (lib.optionals ctx.isLinux [
    (final: prev: {
      # Empty
    })
  ])
]
