{
  ctx,
  lib,
  pkgs,
  config,
  ...
}@args:
let
  pub = builtins.fromTOML (builtins.readFile ../../../.assets/pub.toml);
  symlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  # Apply options so that we can use `config.dotfiles` 
  # to get the dotfiles directory.
  imports = [ ../../../modules/dotfiles.nix ];

  home.stateVersion = "24.11";
  # ┌───────────────────┐
  # │ DEV home.packages │
  # └───────────────────┘
  home.packages =
    with pkgs;
    # ┌─────────────────┐
    # │ packages.common │
    # └─────────────────┘
    [
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
    ]
    # ┌─────────────────┐
    # │ packages.darwin │
    # └─────────────────┘
    ++ lib.optionals ctx.isDarwin [
      pngpaste
    ];

  home.shellAliases = {
    # l = "ls";
    # la = "ls -a";
    # ll = "ls -al";
    # ls = "${pkgs.eza}/bin/eza -g --sort=type";
    vi = "${pkgs.neovim}/bin/nvim";
  };

  # ┌───────────────┐
  # │ DEV home.file │
  # └───────────────┘
  home.file =
    # ┌─────────────┐
    # │ file.common │
    # └─────────────┘
    {
      ".zsh".source = ../../../dotfiles/zsh;
      ".zsh".recursive = true;

      ".scripts".source = ../../../dotfiles/scripts;
      ".scripts".recursive = true;

      ".terminfo".source = ../../../.assets/.terminfo; # No symlink
      ".terminfo".recursive = true;

      "${pub.home.path}".text = pub.home.key;
      "${pub.work.path}".text = pub.work.key;
      "${pub.personal.path}".text = pub.personal.key;
    };

  # ┌────────────────────┐
  # │ DEV xdg.configFile │
  # └────────────────────┘
  xdg.configFile =
    # ┌───────────────────┐
    # │ configFile.common │
    # └───────────────────┘
    {
      "wezterm/wezterm.lua".source = ../../../dotfiles/config/wezterm/wezterm.lua;
      "wezterm/colors/miami.toml".source = ../../../dotfiles/config/wezterm/colors/miami.toml;

      "1Password/ssh/agent.toml".source = ../../../dotfiles/config/1Password/ssh/agent.toml;
    }
    # ┌───────────────────┐
    # │ configFile.darwin │
    # └───────────────────┘
    // lib.optionalAttrs ctx.isDarwin {
      # "yabai/yabairc".source = symlink "${config.dotfiles}/config/yabai/yabairc";
      # "yabai/skhdrc".source = symlink "${config.dotfiles}/config/yabai/skhdrc";
    };

  # ┌──────────────┐
  # │ DEV programs │
  # └──────────────┘
  programs = {
    zsh = import ./programs/zsh.nix args;
    fzf = import ./programs/fzf.nix args;
    fd = import ./programs/fd.nix args;
    tmux = import ./programs/tmux.nix args;
    eza = import ./programs/eza.nix args;
    ssh = import ./programs/ssh.nix args;
    fastfetch = import ./programs/fastfetch.nix args;
    git = import ./programs/git.nix args;
  };

  manual.manpages.enable = true;
}
