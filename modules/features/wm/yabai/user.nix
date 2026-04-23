{ lib, osConfig, ... }:
lib.mkIf (osConfig.features.wm.yabai.enable) {
  xdg.configFile = {
    "yabai/yabairc" = {
      source = ./dotfiles/yabairc;
    };

    "yabai/skhdrc" = {
      source = ./dotfiles/skhdrc;
    };

    "yabai/scripts" = {
      source = ./dotfiles/scripts;
      recursive = true;
    };
  };
}
