{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpicker
    hyprshot
  ];

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
