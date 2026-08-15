{
  lib,
  pkgs,
  osConfig,
  ...
}:
lib.mkIf osConfig.features.wm.hypr.enable {
  programs.zsh.shellAliases = {
    "open" = "nemo";
  };
  home.packages = with pkgs; [
    hyprpicker
    hyprshot
    nemo
  ];

  xdg = {
    portal = {
      enable = true;

      config = {
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };

      # Define a portal backend for Gnome
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        # xdg-desktop-portal-wlr
        xdg-desktop-portal-hyprland
        # xdg-desktop-portal
      ];
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.unstable.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;
    gtk2.enable = true;
    gtk3.enable = true;
    # colorScheme = "dark";

    theme = {
      package = pkgs.unstable.orchis-theme;
      name = "Orchis-Dark-Compact";
    };
    iconTheme = {
      package = pkgs.unstable.tela-icon-theme;
      name = "Tela";
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.serif = [
      "DejaVu Sans"
      "D2Coding"
      "JetBrainsMonoNL Nerd Font"
    ];

    defaultFonts.sansSerif = [
      "DejaVu Sans"
      "D2Coding"
      "JetBrainsMonoNL Nerd Font"
    ];

    defaultFonts.monospace = [
      "JetBrainsMonoNL Nerd Font Mono"
    ];
  };
}
