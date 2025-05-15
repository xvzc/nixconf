{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./base/dev.nix

    ./features/git
    ./features/jetbrains
    ./features/kitty
    ./features/tmux
    ./features/hypr
    ./features/wezterm
    ./features/zsh

    ./features/1password.nix
    ./features/bat.nix
    ./features/direnv.nix
    ./features/eza.nix
    ./features/fd.nix
    ./features/fzf.nix
    ./features/kime.nix
    ./features/neovim.nix
    ./features/ssh.nix
    ./features/wallpaper.nix
  ];

  home.file.".icons/default".source = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 32;
  };
}
