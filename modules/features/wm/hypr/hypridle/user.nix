{
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.features.wm.hypr.enable) {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # avoid starting multiple hyprlock instances.
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";

        # to avoid having to press a key twice to turn on the display.
        after_sleep_cmd = "hyprctl dispatch dpms on";

        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
        ignore_wayland_inhibit = false;
      };

      listener = [
        {
          on-timeout = "hyprlock";
          timeout = 3600;
          condition_cmd = "! pidof hyprlock";
        }
        {
          timeout = 3600 + 3;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
