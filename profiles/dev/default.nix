{
  lib,
  pkgs,
  ctx,
  inputs,
  ...
}:
let
  stateVersion = {
    darwin = 5;
    linux = "24.11";
  };
in
{
  system.stateVersion = stateVersion.${ctx.os};

  time.timeZone = "Asia/Seoul";
  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages =
    with pkgs;
    [
      btop
      coreutils
      curl
      gcc
      gnupg
      htop
      neovim
      openssh
      unzip
      vim
      wget
      zip
    ]
    ++ lib.optionals ctx.isLinux [
      docker_28
      docker-compose
    ];

  nix-homebrew = lib.mkIf ctx.isDarwin {
    enable = true;
    user = "${ctx.user}";
    enableRosetta = false;
    mutableTaps = true; # disable `brew tap <name>`
  };

  homebrew = lib.mkIf ctx.isDarwin {
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
      "wezterm"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    noto-fonts-emoji
    material-design-icons
    nanum-square-neo

    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "D2Coding"
      ];
    })
  ];
}
