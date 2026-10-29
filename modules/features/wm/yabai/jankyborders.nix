{
  lib,
  ctx,
  config,
  ...
}:
lib.mkIf (config.features.wm.yabai.enable) {
  home-manager.users.${ctx.user} = {
    services.jankyborders = {
      enable = true;
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
}
