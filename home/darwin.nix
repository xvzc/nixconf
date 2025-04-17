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
      symlink = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = config.dotfiles;
    in {
      imports = [
        lib.setDotfilesContext
        ./shared/config.nix
        ./shared/files.nix
        ./shared/programs.nix
      ];

      home.activation.setup = builtins.readFile ./_static/darwin/setup.sh;

      home.file."Library/KeyBindings/DefaultKeyBinding.dict".text =
        builtins.readFile ./_static/darwin/DefaultKeyBinding.dict;

      xdg.configFile."aerospace".source = symlink "${dotfiles}/.config/aerospace";
      xdg.configFile."aerospace".recursive = true;

      home.packages = with pkgs; [
        pngpaste
        pam-reattach
      ];
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
