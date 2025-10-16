{
  lib,
  pkgs,
  osConfig,
  config,
  ...
}:
lib.mkIf osConfig.wm.hyprland.enable {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      "$mod1" = "SUPER";
      "$mod2" = "ALT";
      "$mod3" = "CONTROL";
      "$terminal" = "kitty";
      # "$terminal" = "wezterm";
      # "$terminal" = "env -u WAYLAND_DISPLAY wezterm";

      debug = {
        disable_logs = false;
      };

      general = {
        no_focus_fallback = true;
      };

      misc = {
        focus_on_activate = true;
        disable_hyprland_logo = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      input = {
        follow_mouse = 2;
        float_switch_override_focus = 0;
      };

      animations = {
        enabled = true;
        animation = [
          "workspaces, 1, 3, default, slidefade 10%"
          "windows, 1, 2, default, popin 80%"
        ];
      };

      decoration = {
        active_opacity = 0.97;
        inactive_opacity = 0.90;
      };

      exec = [
        # "pkill -9 kime; ${pkgs.kime}/bin/kime"
        # "pkill -9 waybar; ${pkgs.waybar}/bin/waybar"
      ];

      exec-once = [
        "${pkgs.kime}/bin/kime"
        "${pkgs.waybar}/bin/waybar"
        "dunst"

        "hyprctl setcursor Adwaita ${toString config.home.pointerCursor.size}"
        "dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\""
      ];

      windowrule = [
      ];

      windowrulev2 = [
        "noblur,class:^()$,title:^()$"

        "float,title:(Not\ titled.*)"
        "size 300 200,title:(Not\ titled.*)"

        # "stayfocused, class:^(Rofi)$"
      ];

      bind = [
        "$mod1 $mod2 $mod3, r, exec, hyprctl reload"

        "$mod1, Return, exec, $terminal"
        "$mod2, w, killactive"
        ", Pause, exec, hyprlock"

        #sh
        ''
          $mod1, f, exec, hyprctl dispatch togglefloating \
           && (hyprctl activewindow | grep -q "floating: 1" \
           && hyprctl dispatch resizeactive exact 1200 900 \
           && hyprctl dispatch centerwindow) \
           || true
        ''

        "$mod2, Space, exec, python3 ~/.config/rofi/scripts/run-rofi.py"

        "$mod1, h, movefocus, l"
        "$mod1, j, movefocus, d"
        "$mod1, k, movefocus, u"
        "$mod1, l, movefocus, r"

        "$mod1 $mod2, h, swapwindow, l"
        "$mod1 $mod2, j, swapwindow, d"
        "$mod1 $mod2, k, swapwindow, u"
        "$mod1 $mod2, l, swapwindow, r"

        "$mod1, 1, workspace, 1"
        "$mod1, 2, workspace, 2"
        "$mod1, 3, workspace, 3"
        "$mod1, 4, workspace, 4"
        "$mod1, 5, workspace, 5"
        "$mod1, 6, workspace, 6"
        "$mod1, 7, workspace, 7"
        "$mod1, 8, workspace, 8"
        "$mod1, 9, workspace, 9"
        "$mod1, 0, workspace, 10"

        "$mod1 $mod2, 1, movetoworkspace, 1"
        "$mod1 $mod2, 2, movetoworkspace, 2"
        "$mod1 $mod2, 3, movetoworkspace, 3"
        "$mod1 $mod2, 4, movetoworkspace, 4"
        "$mod1 $mod2, 5, movetoworkspace, 5"
        "$mod1 $mod2, 6, movetoworkspace, 6"
        "$mod1 $mod2, 7, movetoworkspace, 7"
        "$mod1 $mod2, 8, movetoworkspace, 8"
        "$mod1 $mod2, 9, movetoworkspace, 9"
        "$mod1 $mod2, 0, movetoworkspace, 10"

        # "$mod1 $mod3, s, exec, rofi -show drun"
        "$mod1 $mod3, s, exec, hyprshot -m region --clipboard-only"
        "$mod1 $mod2 $mod3, s, exec, hyprshot -m region -o ~/.screenshots"
      ];

      bindm = [
        "$mod1, mouse:272, movewindow"
        "$mod1, mouse:273, resizewindow"
        # "$mod ALT, mouse:272, resizewindow"
      ];
    };
  };
}
