{
  lib,
  pkgs,
  config,
  ctx,
  ...
}:
assert ctx.isDarwin;
let
  cfg = config.features.wm.omniwm;

  # nixpkgs repackages the official release, signed with the developer's Team
  # ID, so Accessibility and Input Monitoring grants keep matching after a
  # rebuild moves the store path (no mkMacAppBundle wrapper needed).
  #
  # 0.8.0 is not in nixpkgs yet; drop the override once mv.tip has it.
  package = pkgs.mv.tip.omniwm.overrideAttrs (old: {
    version = "0.8.0";
    src = pkgs.fetchurl {
      url = "https://github.com/OmniNull/OmniWM/releases/download/v0.8.0/OmniWM-v0.8.0.zip";
      hash = "sha256-b3+z4hHeOoPncrExgAaAyz0g1MY4gRofAhIP0iXwPMc=";
    };
  });
in
{
  options.features.wm.omniwm = {
    enable = lib.mkEnableOption "Whether to enable 'omniwm'";
  };

  # dotfiles/settings.toml started as the default file OmniWM 0.7.6 wrote on
  # first launch (its schema is strict: every key not marked optional is
  # required, and an unknown hotkey id rejects the whole file), adjusted to
  # match the yabai + skhd setup: dwindle (bsp-like) layout, gaps of 8 (kept
  # for a lone window too), borders like jankyborders, the skhd hotkeys and the
  # yabai float rules. It is linked read-only, so changes made in the OmniWM
  # settings UI are not saved; edit the file here instead (OmniWM reloads it
  # when it changes).
  #
  # The file is at schema 5 (OmniWM 0.8.0). A new release that bumps the schema
  # upgrades the file by rewriting it, which the read-only link prevents: drop
  # the link for one launch with a writable copy of this file in place, then
  # copy the upgraded file back here.
  #
  # OmniWM needs "Displays have separate Spaces" turned on (spans-displays =
  # false in modules/platforms/darwin/system-preferences.nix), and Accessibility and
  # Input Monitoring granted on first launch.
  config = lib.mkMerge [
    # Once disabled, unload the user agent and remove its plist: switching to
    # another window manager left it running (nix-darwin did not clean it up),
    # and KeepAlive relaunches the app whenever it is quit.
    (lib.mkIf (!cfg.enable) {
      system.activationScripts.postActivation.text = lib.mkOrder 1200 ''
        launchctl bootout "gui/$(id -u ${ctx.user})/org.nixos.omniwm" 2>/dev/null || true
        rm -f "/Users/${ctx.user}/Library/LaunchAgents/org.nixos.omniwm.plist"
      '';
    })

    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            !(config.features.wm.yabai.enable or false) && !(config.features.wm.aerospace.enable or false);
          message = "features.wm.omniwm cannot be enabled together with yabai or aerospace.";
        }
      ];

      environment.systemPackages = [ package ];

      hm.users.default = {
        xdg.configFile."omniwm/settings.toml" = {
          source = ./dotfiles/settings.toml;
          # Replaces the file OmniWM generated on first launch.
          force = true;
        };
      };

      launchd.user.agents.omniwm = {
        serviceConfig = {
          ProgramArguments = [ "${package}/Applications/OmniWM.app/Contents/MacOS/OmniWM" ];
          KeepAlive = true;
          RunAtLoad = true;
          ProcessType = "Interactive";
        };
      };
    })
  ];
}
