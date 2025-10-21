{
  lib,
  config,
  pkgs,
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
}
