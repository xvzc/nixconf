{
  lib,
  osConfig,
  ...
}:
let
  screen_off_timeout = 3600;
  lock_session_timeout = 3600 + 300;
in
lib.mkIf (osConfig.features.wm.hypr.enable) {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # avoid starting multiple hyprlock instances.
        lock_cmd = "pidof hyprlock || hyprlock";

        # lock before suspend.
        before_sleep_cmd = "loginctl lock-session";

        # to avoid having to press a key twice to turn on the display.
        after_sleep_cmd = "hyprctl dispatch dpms on";

        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
        ignore_wayland_inhibit = false;
      };

      listener = [
        {
          timeout = screen_off_timeout;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = lock_session_timeout;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };
}
