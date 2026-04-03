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
    # ./${ctx.platform}

    ../../modules/features/core/git
    ../../modules/features/core/ssh
    ../../modules/features/core/zsh

    ../../modules/features/utils/bat
    ../../modules/features/utils/direnv
    ../../modules/features/utils/eza
    ../../modules/features/utils/fd
    ../../modules/features/utils/fzf

    ../../modules/features/editors/jetbrains
    ../../modules/features/editors/neovim

    ../../modules/features/terms/ghostty
    ../../modules/features/terms/kitty
    ../../modules/features/terms/tmux
    ../../modules/features/terms/wezterm

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
    ../../modules/features/core/chrony
    ../../modules/features/wm/hypr
    ../../modules/features/utils/kime
  ];
}
