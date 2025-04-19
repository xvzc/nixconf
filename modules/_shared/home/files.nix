{config, ...}: let
  dotfiles = config.dotfiles;
  symlink = config.lib.file.mkOutOfStoreSymlink;
in {
  # ┌──────┐
  # │ HOME │
  # └──────┘
  home = {
    ".ssh".source = symlink "${dotfiles}/.ssh";
    ".ssh".recursive = true;

    ".zsh".source = symlink "${dotfiles}/.zsh";
    ".zsh".recursive = true;
    ".zshrc".source = symlink "${dotfiles}/.zshrc";
    ".zshenv".source = symlink "${dotfiles}/.zshenv";

    ".scripts".source = symlink "${dotfiles}/.scripts";
    ".scripts".recursive = true;

    ".fdignore".source = symlink "${dotfiles}/.fdignore";

    ".terminfo".source = symlink "${dotfiles}/.terminfo";
    ".terminfo".recursive = true;
  };

  # ┌─────────────────┐
  # │ XDG_CONFIG_HOME │
  # └─────────────────┘
  xdg = {
    "tmux".source = symlink "${dotfiles}/.config/tmux";
    "tmux".recursive = true;

    "ranger".source = symlink "${dotfiles}/.config/ranger";
    "ranger".recursive = true;

    "lazygit".source = symlink "${dotfiles}/.config/lazygit";
    "lazygit".recursive = true;

    "starship".source = symlink "${dotfiles}/.config/starship";
    "starship".recursive = true;

    "wezterm".source = symlink "${dotfiles}/.config/wezterm";
    "wezterm".recursive = true;

    "1Password".source = symlink "${dotfiles}/.config/1Password";
    "1Password".recursive = true;
  };
}
