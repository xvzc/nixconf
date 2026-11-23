{ lib, ctx, ... }:
assert ctx.isLinux;
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      # kime-wayland dlopens libwayland-client at runtime, but nixpkgs only wraps
      # kime-candidate-window with it; without this it panics with NoWaylandLib.
      kime = final.mv.tip.kime.overrideAttrs (old: {
        # kime-wayland fixes, applied in order:
        patches = (old.patches or [ ]) ++ [
          # v2: Ctrl/Alt/Super re-sent the unchanged preedit, so Chromium replaced
          # the selection with it (select all while composing, then Ctrl -> text gone).
          # Riey/kime#817
          ./patches/01-wayland-skip-redundant-preedit.patch
          # v1: discard the engine state on context reset (Riey/kime#813, fixes #812).
          ./patches/02-wayland-v1-reset-engine.patch
          # v2: pass keys through in password/PIN fields (content_type), as XIM does.
          ./patches/03-wayland-password-passthrough.patch
          # GTK3/4 module: pass keys through in password/PIN fields (input-purpose).
          ./patches/04-gtk-password-passthrough.patch
        ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram "$out/bin/kime-wayland" \
            --prefix LD_LIBRARY_PATH : "${final.lib.makeLibraryPath [ final.wayland ]}"
        '';
      });
    })
  ];

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "kime";
      kime = {
        iconColor = "White";
        extraConfig =
          # yaml
          ''
            log:
              global_level: DEBUG
            engine:
              translation_layer: null
              default_category: Latin
              global_category_state: false
              global_hotkeys:
                Super-Space:
                  behavior: !Toggle
                    - Hangul
                    - Latin
                  result: Consume
                Esc:
                  behavior: !Switch Latin
                  result: Bypass
              hangul:
                # Replaces kime's default addons: drops ComposeChoseongSsang so that
                # ㄱ + ㄱ stays ㄱㄱ (Shift still gives ㄲ), keeps the dubeolsik default.
                addons:
                  all: []
                  dubeolsik:
                    - TreatJongseongAsChoseong
          '';
      };
    };
  };
}
