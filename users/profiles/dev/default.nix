{
 inputs,
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ../../shared/base.nix

    ../../shared/features/app/jetbrains
    ../../shared/features/app/kitty
    ../../shared/features/app/wezterm
    ../../shared/features/app/1password.nix
    ../../shared/features/app/discord.nix
    # ../../shared/features/app/firefox.nix

    ../../shared/features/cli/git
    ../../shared/features/cli/zsh
    ../../shared/features/cli/bat.nix
    ../../shared/features/cli/direnv.nix
    ../../shared/features/cli/eza.nix
    ../../shared/features/cli/fd.nix
    ../../shared/features/cli/fzf.nix
    ../../shared/features/cli/ssh.nix

    ../../shared/features/tui/tmux
    ../../shared/features/tui/neovim.nix

    ./${ctx.os}
  ];

  home.sessionPath = [
    "$HOME/.local/share/JetBrains/Toolbox/scripts"
  ];

  home.packages = with pkgs; [
    # Environment
    cargo
    clang
    go
    nodejs
    (pkgs.python312.withPackages (
      ps: with ps; [
        pip
        pynvim
        python-lsp-server
        flake8
      ]
    ))

    # Language Servers & Formatters
    bash-language-server
    black
    clang-tools
    lua-language-server
    nixd
    nixfmt-rfc-style
    shellcheck
    shfmt
    stylua
    tree-sitter

    cava
    fastfetch
    jq
    ripgrep
    tree
    socat

    # GUI Applications
    google-chrome

    # jetbrains.idea-community-bin
    slack
    spotify
  ];
}
