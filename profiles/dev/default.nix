{
  lib,
  ctx,
  pkgs,
  ...
}:
{
  imports = [
    ../base

    ./system.nix
    { home-manager.users.${ctx.user} = lib.mkMerge [ ./user.nix ]; }

    ../../modules/features/essentials/git
    ../../modules/features/essentials/ssh
    ../../modules/features/essentials/zsh

    ../../modules/features/utils/bat
    ../../modules/features/utils/devenv
    ../../modules/features/utils/eza
    ../../modules/features/utils/fd
    ../../modules/features/utils/fzf

    ../../modules/features/code/ai
    ../../modules/features/code/pi
    ../../modules/features/code/jetbrains
    ../../modules/features/code/neovim

    ../../modules/features/terms/ghostty
    ../../modules/features/terms/kitty
    ../../modules/features/terms/tmux
    ../../modules/features/terms/wezterm
    # ../../modules/features/terms/zellij

    ../../modules/features/gui/1password
    ../../modules/features/gui/discord
    ../../modules/features/gui/firefox
  ]
  # ┌────────┐
  # │ DARWIN │
  # └────────┘
  ++ lib.optionals ctx.isDarwin [
    ../../modules/features/wm/yabai
    ../../modules/features/utils/karabiner
  ]
  # ┌───────┐
  # │ LINUX │
  # └───────┘
  ++ lib.optionals ctx.isLinux [
    ../../modules/features/essentials/chrony
    ../../modules/features/wm/hypr
    ../../modules/features/utils/kime
  ];
}
