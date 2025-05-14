{
  lib,
  ...
}:
{
  imports = [
    ./base/dev.nix

    ./features/git
    ./features/jetbrains
    ./features/tmux
    ./features/wezterm
    ./features/zsh

    ./features/1password.nix
    ./features/bat.nix
    ./features/direnv.nix
    ./features/eza.nix
    ./features/fd.nix
    ./features/fzf.nix
    ./features/neovim.nix
    ./features/ssh.nix
    ./features/wallpaper.nix
  ];
}
