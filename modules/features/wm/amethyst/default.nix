{
  lib,
  config,
  ctx,
  ...
}:
assert ctx.isDarwin;
let
  cfg = config.features.wm.amethyst;

  key = mod: k: {
    inherit mod;
    key = k;
  };

  # Ported from the yabai + skhd setup. Amethyst has no directional focus or
  # swap: windows rotate in layout order, so alt-j/k and cmd-alt-j/k move
  # through them. Switching to space N is not an Amethyst command; it uses the
  # macOS "Switch to Desktop N" shortcuts, set to Option+N by
  # modules/platforms/darwin/system-preferences.nix while Amethyst is enabled (throwing a
  # window to a space needs them too).
  settings = {
    layouts = [
      "bsp"
      "fullscreen"
    ];

    # mod1 = alt, mod2 = cmd + alt, as in skhdrc.
    mod1 = [ "option" ];
    mod2 = [
      "option"
      "command"
    ];

    focus-cw = key "mod1" "j";
    focus-ccw = key "mod1" "k";
    swap-cw = key "mod2" "j";
    swap-ccw = key "mod2" "k";
    toggle-float = key "mod2" "t";
    relaunch-amethyst = key "mod2" "r";
  }
  // lib.listToAttrs (
    map (n: lib.nameValuePair "throw-space-${toString n}" (key "mod2" (toString n))) (lib.range 1 9)
  )
  // {
    # Gaps of 8 between windows and at the screen edges, also for a lone
    # window (smart margins would drop them).
    window-margins = true;
    window-margin-size = 8;
    smart-window-margins = false;
    screen-padding-left = 8;
    screen-padding-right = 8;
    screen-padding-top = 8;
    screen-padding-bottom = 8;

    # yabai manage=off apps. Title-based rules (JetBrains dialogs, "Settings")
    # are not supported; small windows such as dialogs float anyway.
    floating = [
      "com.apple.systempreferences"
      "com.kakao.KakaoTalkMac"
      "com.apple.finder"
      "com.spotify.client"
      "com.1password.1password"
      "com.runningwithcrayons.Alfred"
      "com.openai.chat"
    ];
    floating-is-blacklist = true;
    float-small-windows = true;

    mouse-follows-focus = false;
    focus-follows-mouse = false;
    # skhd's `--space N --focus`: follow a window thrown to another space.
    follow-space-thrown-windows = true;
  };
in
{
  options.features.wm.amethyst = {
    enable = lib.mkEnableOption "Whether to enable 'amethyst'";
  };

  config = lib.mkMerge [
    # Once disabled, unload the user agent and remove its plist: switching to
    # another window manager left it running (nix-darwin did not clean it up),
    # and KeepAlive relaunches the app whenever it is quit.
    (lib.mkIf (!cfg.enable) {
      system.activationScripts.postActivation.text = lib.mkOrder 1200 ''
        launchctl bootout "gui/$(id -u ${ctx.user})/org.nixos.amethyst" 2>/dev/null || true
        rm -f "/Users/${ctx.user}/Library/LaunchAgents/org.nixos.amethyst.plist"
      '';
    })

    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            !(config.features.wm.yabai.enable or false)
            && !(config.features.wm.aerospace.enable or false)
            && !(config.features.wm.omniwm.enable or false);
          message = "features.wm.amethyst cannot be enabled together with yabai, aerospace or omniwm.";
        }
      ];

      # Not in nixpkgs.
      homebrew.casks = [ "amethyst" ];

      hm.users.default = {
        # JSON is valid YAML. Amethyst reads it on launch (cmd-alt-r relaunches).
        home.file.".amethyst.yml".text = builtins.toJSON settings;
      };

      launchd.user.agents.amethyst = {
        serviceConfig = {
          ProgramArguments = [ "/Applications/Amethyst.app/Contents/MacOS/Amethyst" ];
          KeepAlive = true;
          RunAtLoad = true;
          ProcessType = "Interactive";
        };
      };
    })
  ];
}
