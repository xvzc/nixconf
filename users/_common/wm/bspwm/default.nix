{ pkgs, ... }:
{
  imports = [
    ./rofi.nix
  ];

  home.packages = with pkgs; [
    polybar
    dconf
    nitrogen
    bspwm
    picom
    sxhkd
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Adwaita-dark";
      size = 24;
    };
    gtk2.extraConfig = ''
      gtk-theme-name = "Adwaita-dark";
      gtk-icon-theme-namae = "Adwaita-dark";
      gtk-cursor-theme-name = "Adwaita-dark";
    '';
    gtk3.extraConfig = {
      gtk-theme-name = "Adwaita-dark";
      gtk-icon-theme-namae = "Adwaita-dark";
      gtk-cursor-theme-name = "Adwaita-dark";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "Adwaita-dark";
      gtk-icon-theme-namae = "Adwaita-dark";
      gtk-cursor-theme-name = "Adwaita-dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
      color-scheme = "prefer-dark";
    };
  };

  # xdg.configFile."bspwm/bspwmrc".source = ./bspwmrc;
  xdg.configFile."bspwm/picom.conf".source = ./picom.conf;
  xdg.configFile."bspwm/sxhkdrc".source = ./sxhkdrc;

  home.file.".icons/default".source = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  xsession = {
    enable = true;
    initExtra = # sh
      ''
        ${pkgs.kime}/bin/kime
      '';
    windowManager.bspwm = {
      enable = true;
      alwaysResetDesktops = true;
      extraConfig = builtins.readFile ./bspwmrc;
    };
  };

  # xsession.initExtra = ''
  #
  #   # Xcursor.size: 24
  #
  #   exec bspwm
  # '';

  #
  # services.sxhkd = {
  #   enable = true;
  #   extraConfig = builtins.readFile ./sxhkdrc;
  # };
  #
  # services.picom = {
  #   enable = true;
  #   extraArgs = [ "--config ~/.config/bspwm/picom.conf" ];
  # };
}
