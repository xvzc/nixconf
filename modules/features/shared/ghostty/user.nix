{
  ...
}:
{
  xdg.configFile."ghostty/shaders/cursor_warp.glsl".source = ./_files/shaders/cursor_warp.glsl;

  programs.ghostty = {
    enable = true;
    # clearDefaultKeybinds = true;
    settings = {
      theme = "miami";
      custom-shader = "shaders/cursor_warp.glsl";
      # font-size = 10;
      # keybind = [
      #   "ctrl+h=goto_split:left"
      #   "ctrl+l=goto_split:right"
      # ];
    };
    themes = {
      miami = {
        background = "2b2b2b";
        cursor-color = "f8f8f2";
        foreground = "fafae3";
        # Converted RGBA selection color to Hex equivalent and mapped palette based on the provided configuration
        palette = [
          "0=#2b2b2b"
          "1=#db5a53"
          "2=#71d46e"
          "3=#ffba52"
          "4=#90acfc"
          "5=#c28ad1"
          "6=#7accbd"
          "7=#c4c4c4"
          "8=#919191"
          "9=#ff9999"
          "10=#d0e354"
          "11=#fadf7d"
          "12=#a7cafc"
          "13=#f5b5f4"
          "14=#b2ede5"
          "15=#fafae3"
        ];
        selection-background = "44475a";
        selection-foreground = "fafae3";
      };
    };
  };
}
