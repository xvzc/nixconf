{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ../base.nix
    ./overlays.nix
    ./${ctx.os}

    ../../modules/features/shared/jetbrains
    ../../modules/features/shared/kitty
    ../../modules/features/shared/wezterm
    ../../modules/features/shared/1password
    ../../modules/features/shared/discord
    ../../modules/features/shared/firefox

    ../../modules/features/shared/git
    ../../modules/features/shared/zsh
    ../../modules/features/shared/bat
    ../../modules/features/shared/direnv
    ../../modules/features/shared/eza
    ../../modules/features/shared/fd
    ../../modules/features/shared/fzf
    # ../../modules/features/shared/ssh.nix

    ../../modules/features/shared/tmux
    ../../modules/features/shared/neovim

  ];

  environment.pathsToLink = [
    "/share/terminfo"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    noto-fonts-emoji
    material-design-icons
    nanum-square-neo
    d2coding

    nerd-fonts.jetbrains-mono
    nerd-fonts.d2coding
  ];

  home-manager.users.${ctx.user} =
    { ... }:
    {
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
    };
}
