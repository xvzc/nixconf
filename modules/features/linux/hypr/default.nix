{
  lib,
  pkgs,
  ctx,
  config,
  ...
}:
let
  cfg = config.wm.hyprland;
in
{
  options.wm.hyprland = with lib; {
    enable = mkEnableOption "Whether to enable hyprland";
  };

  config = lib.mkIf cfg.enable {
    imports = [
      ./waybar
      ./hypridle.nix
      ./hyprland.nix
      ./hyprlock.nix
      ./hyprpaper.nix
    ];

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    environment.sessionVariables =
      {
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
      nautilus
      wl-clipboard
    ];

    services = {
      xserver.enable = true;

      greetd = {
        enable = true;
        vt = 3;
        settings =
          let
            tuigreetBin = "${pkgs.greetd.tuigreet}/bin/tuigreet";
          in
          {
            default_session = {
              user = "greeter";
              command = "${tuigreetBin} --asterisks --remember";
            };
          };
      };
    };

    home-manager.users.${ctx.user} =
      { ... }:
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
      };
  };
}
