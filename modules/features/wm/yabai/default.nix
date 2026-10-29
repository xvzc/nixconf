{ lib, ctx, config, ... }:
assert ctx.isDarwin;
with lib;
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

  # Unload stale `skhd`/`yabai` user agents left by previous generations.
  # nix-darwin only cleans /Library/Launch{Agents,Daemons}, so per-user
  # ~/Library/LaunchAgents plists would otherwise keep running when disabled.
  config.system.activationScripts.postActivation.text = lib.mkIf (!config.features.wm.yabai.enable) (
    lib.mkOrder 1200 (
      # sh
      ''
        launchctl bootout "gui/$(id -u ${ctx.user})/org.nixos.skhd" || true
        launchctl bootout "gui/$(id -u ${ctx.user})/org.nixos.yabai" || true
        rm -f "/Users/${ctx.user}/Library/LaunchAgents/org.nixos.skhd.plist"
        rm -f "/Users/${ctx.user}/Library/LaunchAgents/org.nixos.yabai.plist"
      ''
    )
  );
}
