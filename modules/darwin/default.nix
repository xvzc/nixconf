{
  inputs,
  pkgs,
  curEnv,
  lib,
  ...
}:
let
  sharedFonts = import ../_shared/fonts.nix { inherit pkgs; };
  sharedPrograms = import ../_shared/programs.nix;
  sharedPkgs = import ../_shared/pkgs.nix {
    inherit pkgs lib curEnv;
  };
in
{
  imports = [ ./settings.nix ];

  users.users.${curEnv.user} = {
    name = "${curEnv.user}";
    home = "/Users/${curEnv.user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${curEnv.user} =
      {
        pkgs,
        ...
      }:
      {
        home = {
          stateVersion = "24.11";
          enableNixpkgsReleaseCheck = false;
          packages = sharedPkgs ++ [ ];
        };

        programs = { } // sharedPrograms;

        manual.manpages.enable = true;
      };
  };

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

  # Fonts
  fonts = {
    packages = sharedFonts;
  };
}
