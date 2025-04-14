{
  inputs,
  curEnv,
  ...
}:
let
in
{
  nix-homebrew = {
    enable = true;
    user = "${curEnv.user}";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "nikitabobko/tap" = inputs.homebrew-aerospace;
    };
    enableRosetta = false;
    mutableTaps = false; # disable `brew tap <name>`
  };

  homebrew = {
    enable = true;
    casks = [
      "1password"
      "alfred"
      "bettertouchtool"
      "aerospace"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
      "Gifski " = 1351639930;
    };
  };
}
