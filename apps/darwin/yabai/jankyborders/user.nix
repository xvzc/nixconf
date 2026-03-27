{
  lib,
  osConfig,
  pkgs,
  ...
}:
lib.mkIf (osConfig.wm.yabai.border && osConfig.wm.yabai.enable) {
  services.jankyborders = {
    enable = true;
    settings = {
      style = "square";
      width = 3.0;
      hidpi = "on";
      active_color = "0xff7ffa5c";
      inactive_color = "0x00000000";
      whitelist="\"wezterm-gui,wezterm,WezTerm\"";
      ax_focus = "on";
    };
  };
}
