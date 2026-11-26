# Hardware support, chosen per host: `platforms.linux.hardware = { cpu = "amd";
# gpu = "nvidia"; };`. Each is off (null) unless set.
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.platforms.linux.hardware;
in
{
  options.platforms.linux.hardware = {
    cpu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "intel"
          "amd"
        ]
      );
      default = null;
      description = "CPU vendor, for its microcode.";
    };
    gpu = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "nvidia" ]);
      default = null;
      description = "GPU vendor, for its driver.";
    };
  };

  config = lib.mkMerge [
    # ┌─────┐
    # │ CPU │
    # └─────┘
    (lib.mkIf (cfg.cpu == "intel") {
      environment.systemPackages = [ pkgs.microcode-intel ];
    })

    (lib.mkIf (cfg.cpu == "amd") {
      environment.systemPackages = [ pkgs.microcode-amd ];
    })

    # ┌─────┐
    # │ GPU │
    # └─────┘
    # The proprietary-API driver (open kernel modules), with VA-API, and what
    # Wayland compositors need on it.
    (lib.mkIf (cfg.gpu == "nvidia") {
      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct";
        WLR_NO_HARDWARE_CURSORS = "1";
      };

      environment.systemPackages = [ pkgs.egl-wayland ];

      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics = {
          enable = true;
          extraPackages = [ pkgs.nvidia-vaapi-driver ];
        };

        nvidia = {
          modesetting.enable = true;
          open = true;
          package = config.boot.kernelPackages.nvidiaPackages.beta;
          nvidiaSettings = true;
          powerManagement.enable = true;
        };
      };
    })
  ];
}
