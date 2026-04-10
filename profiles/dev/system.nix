{
  lib,
  pkgs,
  ctx,
  ...
}:
lib.mkMerge [
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  {
    environment.pathsToLink = [
      "/share/terminfo"
    ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      material-design-icons
      nanum-square-neo
      d2coding

      nerd-fonts.jetbrains-mono
      nerd-fonts.d2coding
    ];
  }
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # ┌────────┐
  # │ DARWIN │
  # └────────┘
  (lib.optionalAttrs ctx.isDarwin {
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
        # "docker"
        "duckduckgo"
      ];

      masApps = {
        "KakaoTalk" = 869223134;
      };
    };

    environment.systemPath = [
      "/opt/homebrew/bin"
    ];
  })
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # ┌───────┐
  # │ LINUX │
  # └───────┘
  (lib.optionalAttrs ctx.isLinux {
    environment.systemPackages = with pkgs; [
      lm_sensors
      pamixer
      tcpdump
      dig
      lsof
    ];

    virtualisation.docker.enable = true;
  })
]
