{
  lib,
  osConfig,
  wallpaper,
  ...
}:
lib.mkIf osConfig.wm.hyprland.enable {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true;
      splash = false;
      splash_offset = 2.0;

      preload = [
        wallpaper
      ];

      wallpaper = lib.mkIf (wallpaper != null) [
        ", ${wallpaper}"
      ];
    };
  };

  systemd.user.services.hyprpaper =
    let
      target = "hyprland-session.target";
    in
    {
      Install = {
        WantedBy = [ target ];
      };

      Unit = {
        # Specifies that hyprpaper must start after the hyprland session target is reached
        After = lib.mkForce [ target ];
        PartOf = lib.mkForce [ target ];
      };
    };
}
