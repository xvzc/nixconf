{
  inputs,
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ../../_base/user.nix

    ../../../shared/user/app/jetbrains
    ../../../shared/user/app/kitty
    ../../../shared/user/app/wezterm
    ../../../shared/user/app/1password.nix
    ../../../shared/user/app/firefox.nix

    ../../../shared/user/cli/git
    ../../../shared/user/cli/zsh
    ../../../shared/user/cli/bat.nix
    ../../../shared/user/cli/direnv.nix
    ../../../shared/user/cli/eza.nix
    ../../../shared/user/cli/fd.nix
    ../../../shared/user/cli/fzf.nix
    ../../../shared/user/cli/ssh.nix

    ../../../shared/user/tui/tmux
    ../../../shared/user/tui/neovim.nix

    ./${ctx.os}.nix
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

    # GUI Applications
    discord
    google-chrome
    # jetbrains.idea-community-bin
    slack
    spotify
  ];
}
