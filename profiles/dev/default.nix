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

    ../../apps/shared/1password
    ../../apps/shared/bat
    ../../apps/shared/direnv
    ../../apps/shared/discord
    ../../apps/shared/eza
    ../../apps/shared/fd
    ../../apps/shared/firefox
    ../../apps/shared/fzf
    ../../apps/shared/ghostty
    ../../apps/shared/git
    ../../apps/shared/jetbrains
    ../../apps/shared/kitty
    ../../apps/shared/neovim
    ../../apps/shared/tmux
    ../../apps/shared/wezterm
    ../../apps/shared/zsh
    ../../apps/shared/ssh
  ];
}
