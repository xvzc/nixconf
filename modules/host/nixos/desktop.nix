{
  lib,
  config,
  pkgs,
  ctx,
  ...
}:
let
  cfg = config.desktop;
  sddm-astronaut = (
    pkgs.unstable.sddm-astronaut.override {
      embeddedTheme = "hyprland_kath";
    }
  );
in
{
  options.desktop = with lib; {
    cpu = mkOption {
      type =
        with types;
        enum [
          "intel"
          "amd"
        ];
    };
    gpu = mkOption {
      type =
        with types;
        enum [
          "nvidia"
        ];
    };
    audio.enable = mkEnableOption "Whether to enable audio";
    windowManager = mkOption {
      type =
        with types;
        enum [
          "bspwm"
          "hypr"
        ];
    };
  };

  config =
    with lib;
    mkMerge [
      (mkIf cfg.audio.enable {
        environment.systemPackages = [
          pkgs.pavucontrol
        ];

        services.pipewire = {
          enable = true;
          audio.enable = true;
          pulse.enable = true;
        };
      })
      # ┌─────┐
      # │ CPU │
      # └─────┘
      (mkIf (cfg.cpu == "intel") {
        environment.systemPackages = [
          pkgs.microcode-intel
        ];
      })

      (mkIf (cfg.cpu == "amd") {
        environment.systemPackages = [
          pkgs.microcode-amd
        ];
      })

      # ┌─────┐
      # │ GPU │
      # └─────┘
      (mkIf (cfg.gpu == "nvidia") {
        environment.sessionVariables = {
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };

        services.xserver.videoDrivers = [ "nvidia" ];
        hardware = {
          nvidia = {
            modesetting.enable = true;
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.beta;
            nvidiaSettings = true;
            powerManagement.enable = true;
          };

          graphics = {
            enable = true;
          };
        };
      })

      # ┌────────────────┐
      # │ WINDOW_MANAGER │
      # └────────────────┘
      (mkIf (cfg.windowManager == "bspwm") {
        environment.sessionVariables = {
          GDK_BACKEND = "x11";
        };

        services = {
          displayManager.ly = {
            enable = true;
            settings = {
              animation = "matrix";
              blank_password = true;
              bigclock = true;
              hide_key_hints = true;
            };
          };
          xserver = {
            enable = true;
            windowManager.bspwm = {
              enable = true;
            };
          };
        };
      })

      (mkIf (cfg.windowManager == "hypr") {
        environment.sessionVariables =
          {
            WLR_NO_HARDWARE_CURSORS = "1";
            NIXOS_OZONE_WL = "1";
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
          }
          // lib.optionals (cfg.gpu == "nvidia") {
            NVD_BACKEND = "direct";
            LIBVA_DRIVER_NAME = "nvidia";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          };

        environment.systemPackages = with pkgs; [
          sddm-astronaut
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
                  command = "${tuigreetBin} --asterisks --time --remember";
                };
              };
          };
        };

        programs.hyprland = {
          enable = true;
          xwayland.enable = true;
          withUWSM = true;
        };
      })
    ];
}
