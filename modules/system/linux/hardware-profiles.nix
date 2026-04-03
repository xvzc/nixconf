{
  lib,
  config,
  pkgs,
  ctx,
  ...
}:
let
  cfg = config.hardware.profiles;
in
{
  options.hardware.profiles = with lib; {
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
    audio = mkOption {
      default = null;
      type =
        with types;
        enum [
          "pipewire"
        ];
    };
  };

  config =
    with lib;
    mkMerge [
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
          LIBVA_DRIVER_NAME = "nvidia";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          NVD_BACKEND = "direct";
        };

        environment.systemPackages = with pkgs; [
          egl-wayland
        ];

        services.xserver.videoDrivers = [ "nvidia" ];
        hardware = {
          opengl.extraPackages = [
            pkgs.nvidia-vaapi-driver
          ];

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

      # ┌───────┐
      # │ AUDIO │
      # └───────┘
      (mkIf (cfg.audio == "pipewire") {
        environment.systemPackages = [
          pkgs.pavucontrol
        ];

        services.pipewire = {
          enable = true;
          audio.enable = true;
          pulse.enable = true;
        };
      })
    ];
}
