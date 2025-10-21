{ lib, osConfig, ... }:
lib.mkIf osConfig.wm.yabai.enable {
  xdg.configFile = {
    "yabai/yabairc" = {
      source = ./_files/yabairc;
    };

    "yabai/skhdrc" = {
      source = ./_files/skhdrc;
    };

    "yabai/scripts" = {
      source = ./_files/scripts;
      recursive = true;
    };
  };
}
