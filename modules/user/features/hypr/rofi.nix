{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    font = "JetBrainsMono Nerd Font Medium 12";
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      display-drun = "";
      display-run = "";
      display-window = "";
    };

    theme = {
      "*" = {
        border = 0;
        margin = 0;
        padding = 0;
        spacing = 0;

        bg = mkLiteral "#2E3440";
        bg-alt = mkLiteral "#3B4252";
        fg = mkLiteral "#81A1C1";
        fg-alt = mkLiteral "#EBCB8B";

        background-color = mkLiteral "@bg";
        text-color = mkLiteral "@fg";
      };

      window = {
        transparency = mkLiteral "\"real\"";
      };

      mainbox = {
        children = map mkLiteral [
          "inputbar"
          "listview"
        ];
      };

      inputbar = {
        background-color = mkLiteral "@bg-alt";
        children = map mkLiteral [
          "prompt"
          "entry"
        ];
      };

      entry = {
        background-color = mkLiteral "inherit";
        padding = mkLiteral "12px 3px";
      };

      prompt = {
        background-color = mkLiteral "inherit";
        padding = mkLiteral "12px";
      };

      listview = {
        lines = 8;
      };

      element = {
        children = map mkLiteral [
          "element-icon"
          "element-text"
        ];
      };

      element-icon = {
        padding = mkLiteral "10px 10px";
      };

      element-text = {
        padding = mkLiteral "10px 0";
      };

      "element-text selected" = {
        text-color = mkLiteral "@fg-alt";
      };
    };
  };
}
