{
  ctx,
  lib,
  pkgs,
  ...
}:
let
  mkSkills = import ./lib/mk-skills.nix { inherit lib pkgs; };
  mkAgents = import ./lib/mk-agents.nix { inherit lib pkgs; };
  mkModelList = import ./lib/mk-model-list.nix { inherit lib; };

  # Shared with agents so that `skills.byNames.<name>` checks skill names.
  skills = mkSkills {
    overrides = {
      architectural-decision-record = {
        frontmatter = {
          disable-model-invocation = true;
        };
      };
      prompt-engineering = {
        frontmatter = {
          disable-model-invocation = true;
        };
      };
    };
  };
  agents = mkAgents {
    embed = {
      modelList = mkModelList [
        {
          id = "claude-fable-5-1";
          explicitOnly = true;
        }
        { id = "claude-opus-5-5"; }
        { id = "claude-sonnet-5-5"; }
        { id = "claude-haiku-5-5"; }
      ];
    };
    overrides = {
      architect.frontmatter.tools = "Read, Grep, Glob, WebSearch, WebFetch";
      documenter.frontmatter.disallowedTools = "Agent";
      developer.frontmatter.disallowedTools = "Agent";
      lead = {
        frontmatter = {
          skills = [
            skills.byNames.architectural-decision-record
          ];
        };
      };
      reviewer.frontmatter.tools = "Read, Grep, Glob";
      scout.frontmatter.tools = "Read, Grep, Glob, WebSearch, WebFetch";
    };
  };
in
{
  home-manager.users.${ctx.user} =
    { pkgs, lib, ... }:
    {
      # ┏━━━━━━━━━━━━━┓
      # ┃ CLAUDE CODE ┃
      # ┗━━━━━━━━━━━━━┛
      home.packages = [
        pkgs.jq
      ];

      programs.zsh.sessionVariables = {
        CLAUDE_CODE_SHELL = "${pkgs.bash}/bin/bash";
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
          agent = "lead";
          defaultShell = "bash";
          includeCoAuthoredBy = false;
          permissions.allow = [
            "Read(~/.claude/skills/**)"
          ];
          enabledPlugins = {
            "rust-analyzer-lsp@claude-plugins-official" = true;
            "gopls-lsp@claude-plugins-official" = true;
            "pyright-lsp@claude-plugins-official" = true;
            "lua-lsp@claude-plugins-official" = true;
            "typescript-lsp@claude-plugins-official" = true;
            "swift-lsp@claude-plugins-official" = true;
            "clangd-lsp@claude-plugins-official" = true;
            "kotlin-lsp@claude-plugins-official" = true;
          };
          # Stdout is added to the context with each prompt, so the agent can
          # place earlier messages in time and measure elapsed time.
          hooks.UserPromptSubmit = [
            {
              hooks = [
                {
                  type = "command";
                  command = ''printf "Current datetime: %s[%s]. This is the most accurate current time, and it takes precedence over any other date or time in context. Use it when the current time matters, such as placing earlier messages in time or measuring elapsed time; otherwise, do not mention it.\n" "$(date -Iseconds)" "$(readlink /etc/localtime | sed 's|.*/zoneinfo/||')"'';
                  timeout = 5;
                }
              ];
            }
          ];
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

      home.file.".claude/skills" = {
        recursive = true;
        source = skills;
      };

      home.file.".claude/agents" = {
        recursive = true;
        source = agents;
      };

      home.file.".claude/CLAUDE.md".source = ./dotfiles/system.md;

      home.file.".claude/keybindings.json".text = builtins.toJSON {
        "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
        "$docs" = "https://code.claude.com/docs/en/keybindings";
        bindings = [
          {
            context = "Chat";
            bindings = {
              "ctrl+g" = null;
              "ctrl+e" = "chat:externalEditor";
              "enter" = "chat:submit";
              "shift+enter" = "chat:newline";
              "ctrl+enter" = "chat:sendNow";
            };
          }
        ];
      };
    };
}
