{
  lib,
  ctx,
  ...
}:
{
  imports = [
    ../base

    ./overlays.nix
    ./system.nix
    { home-manager.users.${ctx.user} = lib.mkMerge [ ./user.nix ]; }
    ./${ctx.platform}

    ../../modules/features/shared/1password
    ../../modules/features/shared/bat
    ../../modules/features/shared/direnv
    ../../modules/features/shared/discord
    ../../modules/features/shared/eza
    ../../modules/features/shared/fd
    ../../modules/features/shared/firefox
    ../../modules/features/shared/fzf
    ../../modules/features/shared/git
    ../../modules/features/shared/jetbrains
    ../../modules/features/shared/kitty
    ../../modules/features/shared/neovim
    ../../modules/features/shared/tmux
    ../../modules/features/shared/wezterm
    ../../modules/features/shared/zsh
  ];
}
