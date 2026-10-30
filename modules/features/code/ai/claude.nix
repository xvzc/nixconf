{ ctx, ... }:
{
  home-manager.users.${ctx.user} =
    { pkgs, lib, ... }:
    {
      # ┏━━━━━━━━━━━━━┓
      # ┃ CLAUDE CODE ┃
      # ┗━━━━━━━━━━━━━┛
      home.file.".claude/rules" = {
        source = ./dotfiles/rules;
        recursive = true;
      };

      home.file.".claude/agents" = {
        source = ./dotfiles/agents;
        recursive = true;
      };

      home.file.".claude/skills" = {
        source = ./dotfiles/skills;
        recursive = true;
      };

      home.file.".claude/keybindings.json".text = builtins.toJSON {
        "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
        "$docs" = "https://code.claude.com/docs/en/keybindings";
        bindings = [
          {
            context = "Chat";
            bindings = {
              "ctrl+g" = null;
              "escape" = null;
              "ctrl+e" = "chat:externalEditor";
              "enter" = "chat:sendNow";
              "shift+enter" = "chat:newline";
              "ctrl+enter" = "chat:submit";
            };
          }
        ];
      };
      #
      # home.file.".claude/settings.json" = {
      #   force = true;
      # };

      programs.zsh.sessionVariables = {
        CLAUDE_CODE_NO_FLICKER = 1;
        CLAUDE_CODE_ENABLE_TASKS = 1;
      }
      // lib.optionalAttrs ctx.isDarwin {
        NODE_EXTRA_CA_CERTS = "/etc/ssl/cert.pem";
      };

      programs.claude-code = {
        enable = true;
        settings = {
          model = "claude-opus-5-5";
          agent = "orchestrator";
          defaultShell = "bash";
          includeCoAuthoredBy = false;
          permissions.allow = [
            "Read(~/.claude/skills/**)"
            "Read(~/.claude/agents/**)"
            "Read(~/.claude/rules/**)"
          ];
          enabledPlugins = {
            "rust-analyzer-lsp@claude-plugins-official" = true;
            "gopls-lsp@claude-plugins-official" = true;
            "pyright-lsp@claude-plugins-official" = true;
            "lua-lsp@claude-plugins-official" = true;
            "typescript-lsp@claude-plugins-official" = true;
          };
          extraKnownMarketplaces = {
            openai-codex = {
              source = {
                source = "github";
                repo = "openai/codex-plugin-cc";
              };
            };
          };
        };
      };
    };
}
