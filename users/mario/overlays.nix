{
  lib,
  ctx,
  inputs,
  ...
}@args:
[
  # ┌─────────────────┐
  # │ COMMON OVERLAYS │
  # └─────────────────┘
  (final: prev: {
    gh = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.gh;
  })

  # ┌─────────────────┐
  # │ DARWIN OVERLAYS │
  # └─────────────────┘
  (lib.mkIf ctx.isDarwin (
    final: prev: {
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
    }
  ))
]
