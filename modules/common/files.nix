{
  config,
  ...
}:
let
  dotfiles = config.dotfiles;
  symlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  home = {
    ".zshrc".source = symlink "${dotfiles}/.zshrc";
    ".zshenv".source = symlink "${dotfiles}/.zshenv";
    ".zsh".source = symlink "${dotfiles}/.zsh";
    ".zsh".recursive = true;

    ".ssh".source = symlink "${dotfiles}/.ssh";
    ".ssh".recursive = true;

    ".scripts".source = symlink "${dotfiles}/.scripts";
    ".scripts".recursive = true;

    ".fdignore".source = symlink "${dotfiles}/.fdignore";

    ".terminfo".source = symlink "${dotfiles}/.terminfo";
    ".terminfo".recursive = true;

    ".gitconfig".source = symlink "${dotfiles}/.gitconfig";
  };

  xdgConfig = {
    "wezterm".source = symlink "${dotfiles}/.config/wezterm";
    "wezterm".recursive = true;
    "wezterm/wezterm.lua".enable = false;

    "tmux".source = symlink "${dotfiles}/.config/tmux";
    "tmux".recursive = true;
    "tmux/tmux.conf".enable = false;

    "lazygit".source = symlink "${dotfiles}/.config/lazygit";
    "lazygit".recursive = true;

    "1Password".source = symlink "${dotfiles}/.config/1Password";
    "1Password".recursive = true;

    "ranger".source = symlink "${dotfiles}/.config/ranger";
    "ranger".recursive = true;

    "starship".source = symlink "${dotfiles}/.config/starship";
    "starship".recursive = true;
  };
}
