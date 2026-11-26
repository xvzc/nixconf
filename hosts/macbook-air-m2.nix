{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../modules/features/wm/yabai
    ../modules/features/wm/aerospace
    ../modules/features/wm/omniwm
    ../modules/features/wm/amethyst
  ];

  config = lib.mkMerge [
    {
      features.wm.yabai.enable = false;
      # features.wm.aerospace.enable = false;
      # features.wm.omniwm.enable = false;
      # features.wm.amethyst.enable = true;

      system.defaults.dock = {
        persistent-others = lib.mkForce [ ];
        persistent-apps = [
          "/Applications/Nix Apps/Firefox.app" # features/gui/firefox installs it there
          "${pkgs.spotify}/Applications/Spotify.app"
          "${pkgs.wezterm}/Applications/WezTerm.app"
        ];
      };

    }
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {
      system.stateVersion = 6;
      hm.users.default.home.stateVersion = "25.05";
    }
  ];
}
