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
          on-timeout = "loginctl lock-session";
          timeout = 3600;
        }
        {
          timeout = 3600 + 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  systemd.user.services.hypridle =
    let
      target = "hyprland-session.target";
    in
    {
      Install.WantedBy = [ target ];

      Unit = {
        # Start after Hyprland has imported WAYLAND_DISPLAY into the user systemd environment.
        After = lib.mkForce [ target ];
        PartOf = lib.mkForce [ target ];
      };
    };
}
