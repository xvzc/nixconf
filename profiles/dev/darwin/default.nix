{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ./overlays.nix

    ../../../modules/features/darwin/yabai

    ../../../modules/host/darwin/system-settings.nix
  ];

  # ┌────────────┐
  # │ NIX_DARWIN │
  # └────────────┘
  environment.systemPackages = [
    pkgs.pam-reattach
  ];

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  nix-homebrew = {
    enable = true;
    user = ctx.user;
    enableRosetta = false;
    # mutableTaps = true; # disable `brew tap <name>`
  };

  homebrew = {
    enable = true;

    casks = [
      "docker"
      "chatgpt"
      "duckduckgo"
      "firefox"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
    };
  };

  environment.systemPath = [
    "/opt/homebrew/bin"
  ];

  # ┌──────────────┐
  # │ HOME_MANAGER │
  # └──────────────┘
  home-manager.users.${ctx.user} =
    { config, ... }:
    {
      targets.darwin.keybindings = {
        "₩" = [ "insertText:" ] ++ [ "`" ];
      };

      home.packages = with pkgs; [
        pngpaste
        im-select
      ];

      home.activation.setWallpaper =
        lib.mkIf (config.wallpaper.source != null) # sh
          ''
            run /usr/bin/osascript <<EOF
              tell application "Finder"
                set desktop picture to POSIX file "${config.wallpaper.source}"
              end tell
            EOF
          '';
    };
}
