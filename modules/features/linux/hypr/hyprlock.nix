{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    { config, ... }:
    {
      programs.hyprlock = {
        enable = true;

        settings = {
          general = {
            disable_loading_bar = true;
            grace = 0;
            hide_cursor = true;
            no_fade_in = false;

            ignore_empty_input = true;
            fail_timeout = 500;
          };

          background = [
            {
              path = config.wallpaper.source;
              blur_passes = 3;
              blur_size = 3;
            }
          ];

          label = [
            {
              # monitor = "DP-2";
              text = "$TIME";
              color = "rgba(242, 243, 244, 0.75)";
              font_size = 95;
              font_family = "JetBrainsMono Nerd Font Propo";
              position = "0, 300";
              halign = "center";
              valign = "center";
            }
            {
              # monitor = "DP-2";
              text = ''cmd[update:1000] echo $(date +"%A, %B %d")'';
              color = "rgba(242, 243, 244, 0.75)";
              font_size = 22;
              font_family = "JetBrainsMono Nerd Font Propo";
              position = "0, 200";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = {
            # monitor = "DP-2";
            size = "200,50";
            outline_thickness = 2;
            dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.35; # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = true;
            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(0, 0, 0, 0.2)";
            font_color = "rgb(255, 255, 255)";
            fade_on_empty = false;
            rounding = -1;
            check_color = "rgb(30, 107, 204)";
            font_family = "JetBrainsMono Nerd Font Propo";
            placeholder_text = ''<span foreground="##cdd6f4"></span>'';
            hide_input = false;
            position = "0, -50";
            halign = "center";
            valign = "center";
          };
        };
      };
    };
}
