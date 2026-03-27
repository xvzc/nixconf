{
  config,
  pkgs,
  ...
}:
let
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  xdg.configFile."rofi/scripts/run-rofi.py".source = ./_files/scripts/run_rofi.py;

  programs.rofi = {
    enable = true;
    font = "JetBrainsMono Nerd Font Medium 12";
    terminal = "${pkgs.kitty}/bin/kitty";
    modes = [
      "drun"
      "calc"
      "power:${pkgs.rofi-power-menu}/bin/rofi-power-menu"
    ];

    plugins = [
      pkgs.rofi-calc
      pkgs.rofi-power-menu
    ];
    extraConfig = {
      display-drun = "";
      display-window = "";
      display-ssh = "󰴽";
      display-calc = "";
      display-clipboard = "";
      entry-power = "⏻";
      sync = true;
      matching = "fuzzy";
      sidebar-mode = true;
      drun-match-fields = "GenericName";

      # KEYBINDS
      kb-element-next = "";
      kb-element-prev = "";
      kb-mode-next = mkLiteral "\"Tab\"";
      kb-mode-previous = mkLiteral "\"ISO_Left_Tab\"";
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
          "mode-switcher"
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

      mode-switcher = {
        enabled = true;
        expand = false;
        spacing = mkLiteral "0px";
        margin = mkLiteral "0px 200px";
        padding = mkLiteral "12px";
        # background-color = mkLiteral "#2E343B";
      };

      button = {
        background-color = mkLiteral "@bg";
        text-color = mkLiteral "@fg";
      };

      "button selected" = {
        background-color = mkLiteral "@fg";
        text-color = mkLiteral "@bg";
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
