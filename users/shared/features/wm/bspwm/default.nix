{ pkgs, ... }:
{
  imports = [
    ./rofi.nix
  ];

  home.packages = with pkgs; [
    (polybar.override {
      pulseSupport = true;
    })
    dconf
    nitrogen
    bspwm
    picom
    sxhkd
    lxappearance
  ];

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme.name = "Adwaita-dark";
  };

  # home.sessionVariables = {
  #   GTK_THEME = "Adwaita-dark";
  #   GTK2_RC_FILES = "$HOME/.gtkrc-2.0";
  #   QT_STYLE_OVERRIDE = "Adwaita-dark";
  # };

  # xdg.configFile."bspwm/bspwmrc".source = ./bspwmrc;
  # xdg.configFile."bspwm/bspwmrc".source = ./bspwmrc;
  xdg.configFile."bspwm/picom.conf".source = ./picom.conf;
  xdg.configFile."bspwm/sxhkdrc".source = ./sxhkdrc;
  # home.file.".xinitrc".text = # sh
  #   ''
  #     ${pkgs.kime}/bin/kime
  #   '';

  # home.file.".icons/default".source = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.unstable.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  xsession = {
    enable = true;
    initExtra = # sh
      ''
        export GTK_THEME="Adwaita-dark";
        export GTK_APPLICATION_PREFER_DARK_THEME=1
        ${pkgs.kime}/bin/kime
        xsetroot -cursor_name left_ptr
      '';
    windowManager.bspwm = {
      enable = true;
      alwaysResetDesktops = true;
      extraConfig = builtins.readFile ./bspwmrc;
    };
  };

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
