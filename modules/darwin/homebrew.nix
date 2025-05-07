{
  lib,
  config,
  ctx,
  ...
}:
let
  cfg = config.darwin.homebrew;
in
with lib;
{

  options.darwin.homebrew = {
    user = mkOption {
      type = types.str;
      default = ctx.user;
    };
  };

  config = {
    nix-homebrew = {
      enable = true;
      user = "${cfg.user}";
      enableRosetta = false;
      mutableTaps = true; # disable `brew tap <name>`
    };

    homebrew = {
      enable = true;
      taps = [
        "daipeihust/tap" # im-select
      ];

      brews = [
        "im-select"
      ];

      casks = [
        "docker"
        "raycast"
        "chatgpt"
        "1password"
      ];

      masApps = {
        "KakaoTalk" = 869223134;
      };
    };
  };
}
