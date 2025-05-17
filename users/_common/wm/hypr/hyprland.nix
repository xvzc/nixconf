{
  inputs,
  pkgs,
  ...
}:
let
  cursor-size = 24;
in
{
  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      $mod1 = SUPER
      $mod2 = ALT
      $terminal = kitty

      exec-once = hyprctl setcursor Adwaita ${toString cursor-size}
      exec-once = dconf write /org/gnome/desktop/interface/cursor-size ${toString cursor-size}
      exec-once = dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
      exec-once = dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

      decoration {
        active_opacity = 0.97
        inactive_opacity = 0.90
      }

      animation {
        animation = workspaces, 1, 3, default, slidefade 10%
        animation = windows, 1, 2, default, popin 80%
      }

      bind = $mod1, Return, exec, $terminal
      bind = $mod2, w, killactive
      bind = $mod1, f, togglefloating,
      bind = $mod2, Space, exec, rofi -show drun

      bind = $mod1, h, movefocus, l
      bind = $mod1, j, movefocus, d
      bind = $mod1, k, movefocus, u
      bind = $mod1, l, movefocus, r

      bind = $mod1 $mod2, h, swapwindow, l
      bind = $mod1 $mod2, j, swapwindow, d
      bind = $mod1 $mod2, k, swapwindow, u
      bind = $mod1 $mod2, l, swapwindow, r

      bind = $mod1, 1, workspace, 1
      bind = $mod1, 2, workspace, 2
      bind = $mod1, 3, workspace, 3
      bind = $mod1, 4, workspace, 4
      bind = $mod1, 5, workspace, 5
      bind = $mod1, 6, workspace, 6
      bind = $mod1, 7, workspace, 7
      bind = $mod1, 8, workspace, 8
      bind = $mod1, 9, workspace, 9
      bind = $mod1, 0, workspace, 10

      bind = $mod1 $mod2, 1, movetoworkspace, 1
      bind = $mod1 $mod2, 2, movetoworkspace, 2
      bind = $mod1 $mod2, 3, movetoworkspace, 3
      bind = $mod1 $mod2, 4, movetoworkspace, 4
      bind = $mod1 $mod2, 5, movetoworkspace, 5
      bind = $mod1 $mod2, 6, movetoworkspace, 6
      bind = $mod1 $mod2, 7, movetoworkspace, 7
      bind = $mod1 $mod2, 8, movetoworkspace, 8
      bind = $mod1 $mod2, 9, movetoworkspace, 9
      bind = $mod1 $mod2, 0, movetoworkspace, 10
    '';
  };
}
