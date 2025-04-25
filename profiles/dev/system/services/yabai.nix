{
  ctx,
  pkgs,
  lib,
  ...
}:
{
  enable = ctx.isDarwin;
  enableScriptingAddition = true;
  config = {
    layout = "bsp";
    window_placement = "second_child";

    window_opacity = "on";
    active_window_opacity = 0.97;
    normal_window_opacity = 0.9;
    top_padding = 8;
    bottom_padding = 8;
    left_padding = 8;
    right_padding = 8;
    window_gap = 8;

    focus_follows_mouse = "autofocus";
    mouse_follows_focus = "off";
  };

  extraConfig =
    # sh
    ''
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add title="^Settings$" manage=off
      yabai -m rule --add app="KakaoTalk" manage=off

      yabai -m rule --add app="Finder" manage=off
      yabai -m rule --add app="Spotify" manage=off
      yabai -m rule --add app="1Password" manage=off
      yabai -m rule --add app="Alfred*" manage=off
      yabai -m rule --add app="ChatGPT" manage=off

      # Jetbrains
      yabai -m rule --add title="Rename" manage=off
      yabai -m rule --add title="Move" manage=off
      yabai -m rule --add title="Delete" manage=off
      yabai -m rule --add title="Add File to Git" manage=off
    '';
}
