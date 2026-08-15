{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.features.wm.hypr.enable) {
  environment.systemPackages = with pkgs; [
    dunst
    wl-clipboard
  ];

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
      };
    };
  };
}
