{ ... }:
{
  xdg.configFile = {
    "yabai/yabairc" = {
      source = ./yabairc;
    };

    "yabai/skhdrc" = {
      source = ./skhdrc;
    };
    "yabai/scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
