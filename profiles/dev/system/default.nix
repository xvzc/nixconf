{
  ctx,
  lib,
  pkgs,
  ...
}@args:
let
in
{
  imports = [ ./os/${ctx.platform}.nix ];

  time.timeZone = "Asia/Seoul";
  environment.pathsToLink = [ "/share/zsh" ];

  # ┌────────────────────────────────┐
  # │ DEV environment.systemPackages │
  # └────────────────────────────────┘
  environment.systemPackages =
    # ┌───────────────────────┐
    # │ systemPackages.common │
    # └───────────────────────┘
    with pkgs;
    [
      btop
      coreutils
      curl
      docker_28
      docker-compose
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
    # ┌───────────────────────┐
    # │ systemPackages.darwin │
    # └───────────────────────┘
    ++ lib.optionals ctx.isDarwin [
      pam-reattach
    ];

  # ┌──────────────────┐
  # │ DEV nix-homebrew │
  # └──────────────────┘
  nix-homebrew = lib.mkIf ctx.isDarwin {
    enable = true;
    user = "${ctx.username}";
    enableRosetta = false;
    mutableTaps = true; # disable `brew tap <name>`
  };

  # ┌───────────────────────┐
  # │ DEV homebrew packages │
  # └───────────────────────┘
  homebrew = lib.mkIf ctx.isDarwin {
    enable = true;
    taps = [
      "daipeihust/tap" # im-select
    ];

    brews = [
      "im-select"
    ];

    casks = [
      "raycast"
      "chatgpt"
      "1password"
      "wezterm"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
    };
  };

  # ┌────────────────────┐
  # │ DEV fonts.packages │
  # └────────────────────┘
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

  # ┌──────────────┐
  # │ DEV services │
  # └──────────────┘
  services =
    # ┌─────────────────┐
    # │ services.darwin │
    # └─────────────────┘
    lib.optionals ctx.isDarwin {
      yabai = import ./services/yabai.nix args;
      skhd = import ./services/skhd.nix args;
    };
}
