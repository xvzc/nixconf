{
  lib,
  config,
  pkgs,
  wallpaper,
  ...
}:
{
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  }
  // lib.optionals (config.hardware.profiles.gpu == "nvidia") {
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  environment.systemPackages = with pkgs; [
    dunst
    xfce.thunar
    wl-clipboard
  ];
  programs.regreet = {
    enable = false;
    # theme = {
    #   name = "Orchis-Dark";
    #   package = pkgs.orchis-theme;
    # };
    #
    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };
    #
    # cursorTheme = {
    #   name = "Qogir";
    #   package = pkgs.qogir-icon-theme;
    # };
    #
    # font = {
    #   name = "Noto Sans";
    #   package = pkgs.noto-fonts;
    #   size = 12;
    # };

    settings = {
      background = {
        path = wallpaper;
        fit = "Cover";
      };
    };
  };

  services.dbus.packages = with pkgs; [ xfce.xfconf ];
  services = {
    xserver = {
      enable = true;
    };

    displayManager = {
      sessionPackages = [
        pkgs.hyprland
      ];

      ly = {
        enable = true;
        settings = {
          animation = "matrix";
          load = true;
          save = true;
        };
        # wayland.enable = true;
      };
    };
    #
    # displayManager.sddm = {
    #   enable = true;
    #   # Use Qt5 version of SDDM if required by specific themes
    #   # package = lib.mkForce pkgs.unstable.libsForQt5.sddm;
    #   package = pkgs.lib.mkForce pkgs.unstable.kdePackages.sddm;
    #
    #   # extraPackages = pkgs.lib.mkForce [ pkgs.libsForQt5.qt5.qtgraphicaleffects ];
    #   # Enable Wayland support if using Hyprland or Plasma Wayland
    #   wayland.enable = true;
    #   # theme = "sugar-candy";
    # };

    # greetd is required for regreet
    # greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       # command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet";;
    #       command = "env GTK_USE_PORTAL=0 GDK_DEBUG=no-portals ${pkgs.cage}/bin/cage -s -mlast -- ${pkgs.regreet}/bin/regreet";
    #       user = "greeter";
    #     };
    #   };
    # };

    # greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       user = "greeter";
    #       command = "${pkgs.hyprland}/bin/start-hyprland";
    #     };
    #   };
    # };
  };
}
