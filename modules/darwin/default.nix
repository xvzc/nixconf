{
  env,
  pkgs,
  overlays,
  ...
}: let
  utils = import ../../lib/utils.nix;
in
  assert env.system == "aarch64-darwin"; {
    nixpkgs.overlays = overlays ++ utils.importListFromDir ./overlays;

    time.timeZone = "Asia/Seoul";

    security.pam.enableSudoTouchIdAuth = true;

    system = import ./system.nix {inherit pkgs env;};

    environment = import ./environment {inherit pkgs;};

    users.users.${env.user} = {
      name = "${env.user}";
      home = "/Users/${env.user}";
      isHidden = false;
      shell = pkgs.zsh;
    };

    home-manager = import ./home {inherit env;};

    nix-homebrew = {
      enable = true;
      user = "${env.user}";
      enableRosetta = false;
      mutableTaps = true; # disable `brew tap <name>`
    };

    homebrew = {
      enable = true;
      brewPrefix = "/opt/homebrew/bin";
      taps = [
        "nikitabobko/tap" # aerospace
        "daipeihust/tap" # im-select
        "laishulu/homebrew" # macism
      ];

      brews = ["im-select"];
      casks = ["raycast" "chatgpt" "1password"];
      masApps = {
        "KakaoTalk" = 869223134;
      };
    };

    fonts.packages = pkgs.callPackage ../_shared/fonts.nix {inherit pkgs;};
  }
