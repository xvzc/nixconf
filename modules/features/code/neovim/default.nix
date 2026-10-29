{ ctx, ... }:
{
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     neovim-unwrapped = final.mv.tip.neovim-unwrapped;
  #   })
  # ];

  home-manager.users.${ctx.user} =
    {
      pkgs,
      ctx,
      lib,
      ...
    }:
    {
      xdg.configFile."nvim/init.lua" = {
        enable = lib.mkForce true;
        source = ./dotfiles/init.lua;
      };

      xdg.configFile."nvim/lua" = {
        source = ./dotfiles/lua;
        recursive = true;
      };

      xdg.configFile."nvim/after" = {
        source = ./dotfiles/after;
        recursive = true;
      };

      xdg.configFile."nvim/ftdetect" = {
        source = ./dotfiles/ftdetect;
        recursive = true;
      };

      home.sessionVariables = {
        VISUAL = "nvim";
      };

      programs.neovim = {
        enable = true;
        package = pkgs.mv.tip.neovim-unwrapped;
        defaultEditor = true;
        sideloadInitLua = true;
        extraPackages =
          with pkgs;
          [
            bash-language-server
            shellcheck
            shfmt
          ]
          ++ lib.optionals ctx.isLinux [ wl-clipboard ];

        plugins =
          let
            vp = pkgs.mv.tip.vimPlugins;
            cbox-nvim = pkgs.mv.tip.vimUtils.buildVimPlugin {
              pname = "cbox.nvim";
              version = "unstable-f150e3a";
              src = pkgs.fetchFromGitHub {
                owner = "xvzc";
                repo = "cbox.nvim";
                rev = "f150e3aa8f287111d34cab3646fdc76615ee461b";
                hash = "sha256-JdNyEV8L2y961voTBbPp6z2odFBQ1Irvx17H/CEyx74=";
              };
            };
          in
          [
            vp.catppuccin-nvim
            vp.nvim-web-devicons
            vp.nvim-treesitter-textobjects
            vp.nvim-lspconfig
            vp.snacks-nvim
            vp.blink-cmp
            vp.blink-pairs
            vp.nvim-surround
            vp.friendly-snippets
            vp.tmux-nvim
            vp.nvim-tree-lua
            vp.bufferline-nvim
            vp.oil-nvim
            vp.conform-nvim
            vp.outline-nvim
            vp.lualine-nvim
            vp.noice-nvim
            vp.nvim-notify
            vp.nui-nvim
            vp.gitsigns-nvim
            vp.vim-lastplace
            cbox-nvim
            vp.indent-blankline-nvim
            (vp.nvim-treesitter.withPlugins (p: [
              p.query
              p.c
              p.cpp
              p.go
              p.html
              p.lua
              p.vim
              p.bash
              p.dockerfile
              p.kotlin
              p.java
              p.python
              p.regex
              p.ruby
              p.tsx
              p.typescript
              p.javascript
              p.hcl
              p.cmake
              p.markdown
              p.gomod
              p.sql
              p.terraform
              p.nix
              p.xml
              p.typst
            ]))
          ];

        viAlias = true;

        withPython3 = false;
        withRuby = false;
        withPerl = false;
        withNodeJs = false;
      };
    };
}
