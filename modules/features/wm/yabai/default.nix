{
  lib,
  ctx,
  config,
  ...
}:
assert ctx.isDarwin;
with lib;
let
  previewAbi = "-arm64e_preview_abi";
  previewAbiDeclared = elem previewAbi (
    splitString " " (config.system.nvram.variables."boot-args" or "")
  );
in
{
  options.features.wm.yabai = {
    enable = mkEnableOption "Whether to enable 'yabai'";
  };

  imports = [
    ./yabai.nix
    ./skhd.nix
    ./jankyborders.nix
  ];

  # ┌────────┐
  # │ DARWIN │
  # └────────┘
  config.nixpkgs.overlays = [
    (
      final: prev:
      let
        mkMacAppBundle = import ../../../../lib/mk-mac-app-bundle.nix { pkgs = final; };
      in
      {
        skhd = mkMacAppBundle {
          package = final.mv.tip.skhd;
          identifier = "local.nix.skhd";
        };
        yabai = mkMacAppBundle {
          package = final.mv.tip.yabai;
          identifier = "local.nix.yabai";
        };
        jankyborders = mkMacAppBundle {
          package = final.mv.tip.jankyborders;
          identifier = "local.nix.borders";
          mainProgram = "borders";
        };
      }
    )
  ];

  config.system.activationScripts.postActivation.text = lib.mkMerge [
    # Unload stale `skhd`/`yabai` user agents left by previous generations.
    # nix-darwin only cleans /Library/Launch{Agents,Daemons}, so per-user
    # ~/Library/LaunchAgents plists would otherwise keep running when disabled.
    (lib.mkIf (!config.features.wm.yabai.enable) (
      lib.mkOrder 1200 (
        # sh
        ''
          launchctl bootout "gui/$(id -u ${ctx.user})/org.nixos.skhd" 2>/dev/null ||
            echo "skhd agent not loaded (yabai is disabled); nothing to unload"
          launchctl bootout "gui/$(id -u ${ctx.user})/org.nixos.yabai" 2>/dev/null ||
            echo "yabai agent not loaded (yabai is disabled); nothing to unload"
          rm -f "/Users/${ctx.user}/Library/LaunchAgents/org.nixos.skhd.plist"
          rm -f "/Users/${ctx.user}/Library/LaunchAgents/org.nixos.yabai.plist"
        ''
      )
    ))

    # system.nvram.variables does not unset what it set before, so the
    # -arm64e_preview_abi flag that yabai.nix adds to boot-args stays after
    # yabai is disabled. Drop it whenever the configuration no longer declares
    # it in boot-args; any other boot-args are kept. Takes effect on the next
    # boot.
    (lib.mkIf (!previewAbiDeclared) (
      lib.mkOrder 1210 (
        # sh
        ''
          # nvram exits 1 when boot-args is not set.
          boot_args=$({ nvram boot-args 2>/dev/null || true; } | cut -f2-)
          case " $boot_args " in
            *" ${previewAbi} "*)
              # grep exits 1 when the flag was the only boot-arg; the
              # activation script runs with set -e and pipefail.
              rest=$(printf '%s\n' "$boot_args" | tr -s ' ' '\n' | { grep -vx -e '${previewAbi}' -e "" || true; } | paste -sd ' ' -)
              if [ -n "$rest" ]; then
                nvram boot-args="$rest"
              else
                nvram -d boot-args
              fi
              ;;
          esac
        ''
      )
    ))
  ];
}
