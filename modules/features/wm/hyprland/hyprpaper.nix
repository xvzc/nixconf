{ ... }:
{
  hm.users.default =
    {
      lib,
      osConfig,
      wallpaper,
      ...
    }:
    lib.mkIf (osConfig.features.wm.hyprland.enable) {
      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = true;
          splash = false;

          # hyprpaper >= 0.8: `preload` is gone and `wallpaper` is a category block.
          wallpaper = lib.mkIf (wallpaper != null) [
            {
              monitor = "*";
              path = wallpaper;
              fit_mode = "cover";
            }
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
    };
}
