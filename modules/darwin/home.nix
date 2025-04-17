{
  curEnv,
  lib,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    users.${curEnv.user} = {
      pkgs,
      config,
      ...
    }: let
      commonFiles = import ../common/files.nix {inherit config;};
      commonPkgs = import ../common/pkgs.nix {inherit pkgs;};
      commonPrograms = import ../common/programs.nix {inherit pkgs config;};
      symlink = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = config.dotfiles;
    in {
      imports = [lib.setDotfilesContext];

      home = {
        stateVersion = "24.11";
        enableNixpkgsReleaseCheck = false;

        activation.setup = builtins.readFile ../../_static/darwin/setup.sh;

        file =
          commonFiles.home
          // {
            "Library/KeyBindings/DefaultKeyBinding.dict".text =
              builtins.readFile ../../_static/darwin/DefaultKeyBinding.dict;
          };

        packages = with pkgs; [
          pngpaste
          jankyborders
        ];
      };

      xdg.configFile =
        commonFiles.xdgConfig
        // {
          "aerospace".source = symlink "${dotfiles}/.config/aerospace";
          "aerospace".recursive = true;
        };

      programs =
        commonPrograms
        // {
        };

      manual.manpages.enable = true;
    };
  };

  homebrew = {
    enable = true;
    taps = [
      "nikitabobko/tap" # aerospace
      "daipeihust/tap" # im-select
    ];

    brews = [
      "im-select"
    ];

    casks = [
      "1password"
      "1password-cli"
      "google-chrome"
      "aerospace"
      "bettertouchtool"
      "discord"
      "wezterm"
      "chatgpt"
      "raycast"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
      "Gifski " = 1351639930;
      "Slack" = 803453959;
    };
  };
}
