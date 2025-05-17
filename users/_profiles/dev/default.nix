{
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ../base.nix

    ../../_common/app/jetbrains
    ../../_common/app/kitty
    ../../_common/app/wezterm
    ../../_common/app/1password.nix

    ../../_common/cli/git
    ../../_common/cli/zsh
    ../../_common/cli/bat.nix
    ../../_common/cli/direnv.nix
    ../../_common/cli/eza.nix
    ../../_common/cli/fd.nix
    ../../_common/cli/fzf.nix
    ../../_common/cli/ssh.nix

    ../../_common/tui/tmux
    ../../_common/tui/neovim.nix

    ../../../modules/user/wallpaper.nix
    ./for-${ctx.os}.nix
  ];

  home.sessionPath = [
    "$HOME/.local/share/JetBrains/Toolbox/scripts"
  ];

  home.packages = with pkgs; [
    # Environment
    cargo
    clang_19
    go
    nodejs_22
    (pkgs.python312.withPackages (
      ps: with ps; [
        pip
        pynvim
      ]
    ))

    # Language Servers & Formatters
    bash-language-server
    clang-tools
    lua-language-server
    nixd
    nixfmt-rfc-style
    shellcheck
    shfmt
    stylua
    tree-sitter

    fastfetch
    jq
    ripgrep
    tree

    # GUI Applications
    discord
    google-chrome
    slack
    spotify
  ];
}
