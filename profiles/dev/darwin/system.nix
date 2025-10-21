{ pkgs, ctx, ... }:
{
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
      "duckduckgo"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
    };
  };

  environment.systemPath = [
    "/opt/homebrew/bin"
  ];
}
