{
  pkgs,
  ...
}:
{
  homebrew = {
    enable = true;

    casks = [
      "karabiner-elements"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
    };
  };
}
