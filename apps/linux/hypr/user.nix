{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpicker
    hyprshot
  ];

  xdg = {
    portal = {
      enable = true;

      config = {
        common = {
          default = "gtk"; # Use the GTK (GNOME) file picker
          # "org.freedesktop.impl.portal.FileChooser" = "org.gnome.Nautilus";
          "org.freedesktop.impl.portal.FileChooser" = "thunar";
        };
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

    mimeApps = {
      enable = true;
      defaultApplications = {
        # "inode/directory" = "org.gnome.Nautilus.desktop";
        "inode/directory" = "thunar.desktop";
      };
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    # hyprcursor.enable = true;
    package = pkgs.unstable.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.unstable.orchis-theme;
      name = "Orchis-Grey-Dark";
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
