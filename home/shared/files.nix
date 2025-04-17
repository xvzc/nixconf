{config, ...}: let
  dotfiles = config.dotfiles;
  symlink = config.lib.file.mkOutOfStoreSymlink;
in {
  # ┌──────┐
  # │ HOME │
  # └──────┘
  home.file.".ssh".source = symlink "${dotfiles}/.ssh";
  home.file.".ssh".recursive = true;

  home.file.".zsh".source = symlink "${dotfiles}/.zsh";
  home.file.".zsh".recursive = true;
  home.file.".zshrc".source = symlink "${dotfiles}/.zshrc";
  home.file.".zshenv".source = symlink "${dotfiles}/.zshenv";

  home.file.".scripts".source = symlink "${dotfiles}/.scripts";
  home.file.".scripts".recursive = true;

  home.file.".fdignore".source = symlink "${dotfiles}/.fdignore";

  home.file.".terminfo".source = symlink "${dotfiles}/.terminfo";
  home.file.".terminfo".recursive = true;

  home.file.".gitconfig".source = symlink "${dotfiles}/.gitconfig";

  # ┌─────────────────┐
  # │ XDG_CONFIG_HOME │
  # └─────────────────┘
  xdg.configFile."tmux".source = symlink "${dotfiles}/.config/tmux";
  xdg.configFile."tmux".recursive = true;

  xdg.configFile."ranger".source = symlink "${dotfiles}/.config/ranger";
  xdg.configFile."ranger".recursive = true;

  xdg.configFile."lazygit".source = symlink "${dotfiles}/.config/lazygit";
  xdg.configFile."lazygit".recursive = true;

  xdg.configFile."starship".source = symlink "${dotfiles}/.config/starship";
  xdg.configFile."starship".recursive = true;

  xdg.configFile."wezterm".source = symlink "${dotfiles}/.config/wezterm";
  xdg.configFile."wezterm".recursive = true;

  xdg.configFile."1Password".source = symlink "${dotfiles}/.config/1Password";
  xdg.configFile."1Password".recursive = true;
}
