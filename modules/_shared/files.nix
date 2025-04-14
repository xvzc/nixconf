{
  config,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/nixfiles/dotfiles";
in
{
  home.file.".zshrc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.zshrc";
  };

  home.file.".zshenv" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.zshenv";
  };

  home.file.".fdignore" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.fdignore";
  };

  home.file.".terminfo" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.terminfo";
    recursive = true;
  };

  home.file.".zsh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.zsh";
    recursive = true;
  };


  xdg.configFile = {
    "tmux" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/tmux";
      recursive = true;
    };

    "wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/wezterm";
      recursive = true;
    };
    "lazygit" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/lazygit";
      recursive = true;
    };

    "1Password" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/1Password";
      recursive = true;
    };

    "ranger" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/ranger";
      recursive = true;
    };

    "starship" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/starship";
      recursive = true;
    };
  };
}
