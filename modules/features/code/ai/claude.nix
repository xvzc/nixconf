{ ctx, ... }:
{
  home-manager.users.${ctx.user} =
    { pkgs, lib, ... }:
    let
      mkAgents = import ./lib/mk-agents.nix { inherit lib pkgs; };
      mkModelList = import ./lib/mk-model-list.nix { inherit lib; };

      defaultModel = "claude-opus-5-5";

      models = [
        {
          id = "claude-fable-5-1";
          explicitOnly = true;
        }
        { id = "claude-opus-5-5"; }
        { id = "claude-sonnet-5-5"; }
        { id = "claude-haiku-5-5"; }
      ];

    in
    {
      # ┏━━━━━━━━━━━━━┓
      # ┃ CLAUDE CODE ┃
      # ┗━━━━━━━━━━━━━┛
      home.packages = [
        pkgs.nono
        pkgs.jq
      ];

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
          model = defaultModel;
          agent = "orchestrator";
          defaultShell = "bash";
          includeCoAuthoredBy = false;
          permissions.allow = [
            "Read(~/.claude/skills/**)"
            "Read(~/.claude/agents/**)"
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
      home.file.".claude/agents" = {
        source = mkAgents {
          architect = {
            enable = true;
            tools = "Read, Grep, Glob";
          };
          documenter = {
            enable = true;
            disallowedTools = "Agent";
          };
          engineer = {
            enable = true;
            disallowedTools = "Agent";
          };
          orchestrator = {
            enable = true;
            vars.modelList = mkModelList models;
          };
          reviewer = {
            enable = true;
            hooks.PreToolUse = [
              {
                matcher = "Bash";
                hooks = [
                  {
                    type = "command";
                    command = ''
                      ${./dotfiles/hooks/nono-wrapper.sh} --profile
                      ${./dotfiles/nono-readonly.json}
                    '';
                  }
                ];
              }
            ];
            tools = "Read, Bash";
          };
          scout = {
            enable = true;
            hooks.PreToolUse = [
              {
                matcher = "Bash";
                hooks = [
                  {
                    type = "command";
                    command = ''
                      ${./dotfiles/hooks/nono-wrapper.sh} --profile
                      ${./dotfiles/nono-readonly.json}
                    '';
                  }
                ];
              }
            ];
            tools = "Read, Bash, WebSearch, WebFetch";
          };
        };
        recursive = true;
      };
    };
}
