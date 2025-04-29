{
  pkgs,
  utils,
  ...
}@args:
let
  pub = builtins.fromTOML (builtins.readFile ../../../.assets/pub.toml);
in
{
  home.stateVersion = "24.11";
  manual.manpages.enable = true;

  home.packages = with pkgs; [
    # GUI Applications
    _1password-gui
    _1password-cli
    alacritty
    discord
    google-chrome
    slack
    spotify
    wezterm

    # Environment
    cargo
    go
    nodejs_20
    (pkgs.python312.withPackages (
      ps: with ps; [
        pip
        pynvim
      ]
    ))

    # Language Servers & Formatters
    nixfmt-rfc-style
    bash-language-server
    clang-tools
    clang_19
    lua-language-server
    nixd
    shellcheck
    shfmt
    stylua
    tree-sitter

    # Tools & Utilities
    bat
    fd
    fzf
    gh
    git
    jq
    ripgrep
    tmux
    tree

    # Misc
    neofetch
  ];

  programs = {
    eza = import ./programs/eza.nix args;
    fastfetch = import ./programs/fastfetch.nix args;
    fd = import ./programs/fd.nix args;
    fzf = import ./programs/fzf.nix args;
    git = import ./programs/git.nix args;
    ssh = import ./programs/ssh.nix args;
    tmux = import ./programs/tmux.nix args;
    zsh = import ./programs/zsh.nix args;
  };

  home.file = {
    ".zsh" = {
      source = ../../../dotfiles/zsh;
      recursive = true;
    };

    ".scripts" = {
      source = ../../../dotfiles/scripts;
      recursive = true;
    };

    ".terminfo" = {
      source = ../../../.assets/terminfo;
      recursive = true;
    };

    ".ssh" = {
      source = ../../../dotfiles/ssh;
      recursive = true;
    };
  };

  xdg.configFile = {
    "wezterm" = {
      source = ../../../dotfiles/config/wezterm;
      recursive = true;
    };

    "1Password" = {
      source = ../../../dotfiles/config/1Password;
      recursive = true;
    };
  };
}
