{
  lib,
  ctx,
  config,
  ...
}:
assert ctx.isDarwin;
let
  cfg = config.features.wm.aerospace;

  # alt-<n> focuses workspace <n>, cmd-alt-<n> sends the window there and
  # follows it (key 0 is workspace 10), as with skhd + yabai.
  workspaceKeys = map toString (lib.range 1 9) ++ [ "0" ];
  workspaceOf = key: if key == "0" then "10" else key;
  workspaceBindings = lib.listToAttrs (
    lib.concatMap (key: [
      (lib.nameValuePair "alt-${key}" "workspace ${workspaceOf key}")
      (lib.nameValuePair "cmd-alt-${key}" [
        "move-node-to-workspace ${workspaceOf key}"
        "workspace ${workspaceOf key}"
      ])
    ]) workspaceKeys
  );

  # Windows left unmanaged (floating), ported from the yabai `manage=off` rules.
  float = cond: {
    "if" = cond;
    run = [ "layout floating" ];
  };
in
{
  options.features.wm.aerospace = {
    enable = lib.mkEnableOption "Whether to enable 'aerospace'";
  };

  config = lib.mkMerge [
    # Once disabled, unload the user agent and remove its plist: switching to
    # another window manager left it running (nix-darwin did not clean it up),
    # and KeepAlive relaunches the app whenever it is quit.
    (lib.mkIf (!cfg.enable) {
      system.activationScripts.postActivation.text = lib.mkOrder 1200 ''
        launchctl bootout "gui/$(id -u ${ctx.user})/org.nixos.aerospace" 2>/dev/null || true
        rm -f "/Users/${ctx.user}/Library/LaunchAgents/org.nixos.aerospace.plist"
      '';
    })

    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = !(config.features.wm.yabai.enable or false);
          message = "features.wm.aerospace and features.wm.yabai cannot be enabled together.";
        }
      ];

      services.aerospace = {
        enable = true;
        settings = {
          gaps = {
            inner.horizontal = 8;
            inner.vertical = 8;
            outer.left = 8;
            outer.bottom = 8;
            outer.top = 8;
            outer.right = 8;
          };

          mode.main.binding = workspaceBindings // {
            cmd-alt-ctrl-r = "reload-config";

            alt-enter = "exec-and-forget ~/.local/bin/_open-wezterm";

            alt-h = "focus left";
            alt-j = "focus down";
            alt-k = "focus up";
            alt-l = "focus right";

            # --swap-focus: the focus stays on the moved window, as with yabai.
            cmd-alt-h = "swap --swap-focus left";
            cmd-alt-j = "swap --swap-focus down";
            cmd-alt-k = "swap --swap-focus up";
            cmd-alt-l = "swap --swap-focus right";

            cmd-alt-t = "layout floating tiling";
            cmd-alt-b = "balance-sizes";
          };

          on-window-detected = [
            (float { app-name-regex-substring = "^System Settings$"; })
            (float { window-title-regex-substring = "^Settings$"; })
            (float { app-name-regex-substring = "KakaoTalk"; })
            (float { app-name-regex-substring = "Finder"; })
            (float { app-name-regex-substring = "Spotify"; })
            (float { app-name-regex-substring = "1Password"; })
            (float { app-name-regex-substring = "Alfred"; })
            (float { app-name-regex-substring = "ChatGPT"; })
            # JetBrains dialogs
            (float { window-title-regex-substring = "Rename|Move|Delete|Add File to Git"; })
          ];
        };
      };

      home-manager.users.${ctx.user} = {
        home.file.".local/bin/_open-wezterm" = {
          source = ./dotfiles/scripts/_open-wezterm;
          executable = true;
        };

        # Same borders as with yabai (modules/features/wm/yabai/jankyborders.nix).
        services.jankyborders = {
          enable = false;
          settings = {
            style = "square";
            width = 3.0;
            hidpi = "on";
            active_color = "0xff7ffa5c";
            inactive_color = "0x00000000";
            whitelist = "\"wezterm-gui,wezterm,WezTerm,ghostty\"";
            ax_focus = "on";
          };
        };
      };
    })
  ];
}
