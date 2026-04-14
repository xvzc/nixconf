{
  lib,
  osConfig,
  pkgs,
  ...
}:
lib.mkIf (osConfig.features.wm.yabai.enable && osConfig.features.wm.yabai.border) {
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
}
