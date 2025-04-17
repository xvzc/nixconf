{
  curEnv,
  lib,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    users.${curEnv.user} =
      {
        pkgs,
        config,
        ...
      }:
      let
        commonFiles = import ../common/files.nix { inherit config; };
        commonPkgs = import ../common/pkgs.nix { inherit pkgs; };
        commonPrograms = import ../common/programs.nix { inherit pkgs config; };
        symlink = config.lib.file.mkOutOfStoreSymlink;
        dotfiles = config.dotfiles;
      in
      {
        imports = [ lib.setDotfilesContext ];

        home = {
          stateVersion = "24.11";
          enableNixpkgsReleaseCheck = false;

          activation.link1PasswordAgent = # sh
            ''
              mkdir -p ~/.1password && \
              ln -sf ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \
              ~/.1password/agent.sock && \
              ln -sf /Applications/1Password.app/Contents/MacOS/op-ssh-sign \
              ~/.1password/op-ssh-sign && \
            '';

          file = commonFiles.home // {
          };

          packages =
            with pkgs;
            [
              pngpaste
              jankyborders
            ]
            ++ commonPkgs.home;
        };

        xdg.configFile = commonFiles.xdgConfig // {
          "aerospace".source = symlink "${dotfiles}/.config/aerospace";
          "aerospace".recursive = true;
          # "aerospace/aerospace.toml".enable = false;
        };

        programs = commonPrograms // {
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
      "google-chrome"
      "1password"
      "alfred"
      "aerospace"
      "bettertouchtool"
      "discord"
      "wezterm"
      "chatgpt"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
      "Gifski " = 1351639930;
      "Slack" = 803453959;
    };
  };
}
