{
  pkgs,
  ctx,
  lib,
  ...
}@args:
let
in
{
  home.stateVersion = "24.11";
  # home.username = ctx.user;
  # home.homeDirectory = "/Users/${ctx.user}";

  targets.darwin.keybindings = lib.mkIf ctx.isDarwin {
    "₩" = [ "insertText:" ] ++ [ "`" ];
  };

  home.packages =
    with pkgs;
    [
      # home-manager
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
      pure-prompt
    ]
    ++ lib.optionals ctx.isDarwin [
      pngpaste
    ];

  programs = {
    home-manager.enable = true;
    eza = import ../_shared/programs/eza.nix args;
    fastfetch = import ../_shared/programs/fastfetch.nix args;
    fd = import ../_shared/programs/fd.nix args;
    fzf = import ../_shared/programs/fzf.nix args;
    git = import ../_shared/programs/git.nix args;
    ssh = import ../_shared/programs/ssh.nix args;
    tmux = import ../_shared/programs/tmux.nix args;
    zsh = import ../_shared/programs/zsh.nix args;
  };

  home.file = {
    ".zsh" = {
      source = ../../dotfiles/zsh;
      recursive = true;
    };

    ".scripts" = {
      source = ../../dotfiles/scripts;
      recursive = true;
    };

    ".ssh" = {
      source = ../../dotfiles/ssh;
      recursive = true;
    };

    ".terminfo" = {
      source = ../../.assets/terminfo;
      recursive = true;
    };
  };

  xdg.configFile =
    {
      "nvim".source = pkgs.fetchgit {
        url = "https://github.com/xvzc/nvim.git";
        rev = "HEAD";
        sha256 = "zBMMZiSh/QtJYSd4AC70vPu3xbBI32H/fDZ74m4A75Q=";
      };

      "wezterm" = {
        source = ../../dotfiles/config/wezterm;
        recursive = true;
      };

      "1Password" = {
        source = ../../dotfiles/config/1Password;
        recursive = true;
      };
    }
    // lib.optionals ctx.isDarwin {
      "yabai" = {
        source = ../../dotfiles/config/yabai;
        recursive = true;
      };
    };
}
