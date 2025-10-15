{
  lib,
  pkgs,
  ctx,
  config,
  ...
}:
let
  cfg = config.wm.yabai;
in
{
  config = lib.mkIf cfg.border {
    home-manager.users.${ctx.user} =
      { ... }:
      {
        services.jankyborders = {
          enable = true;
          settings = {
            style = "round";
            width = 2.0;
            hidpi = "on";
            active_color = "0xffe2e2e3";
            inactive_color = "0x00000000";
            ax_focus = "on";
          };
        };
      };
  };
}
