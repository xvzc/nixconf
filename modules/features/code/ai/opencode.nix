{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
  };

  xdg.configFile."opencode/skills" = {
    source = ./dotfiles/skills;
    recursive = true;
  };

  xdg.configFile."opencode/commands" = {
    source = ./dotfiles/commands;
    recursive = true;
  };

  xdg.configFile."opencode/tui.jsonc".text = builtins.toJSON {
    theme = "github";
    keybinds = {
      "leader" = "ctrl+x";

      "editor_open" = "ctrl+e";

      "input_submit" = "return";
      "input_newline" = "shift+return";
      "input_line_home" = "none";
      "input_line_end" = "none";

      "agent_cycle" = "tab";
      "agent_cycle_reverse" = "shift+tab";

      "session_child_first" = "<leader>j";
      "session_parent" = "<leader>k";
      "session_child_cycle" = "<leader>l";
      "session_child_cycle_reverse" = "<leader>h";
      "session_list" = "none";
      "messages_toggle_conceal" = "none";
      "session_compact" = "<leader>shift+c";

      "command_list" = "<leader>c";
      "tips_toggle" = "none";
    };
  };

  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    autoupdate = false;
    instructions = [
      ".agents/AGENTS.md"
      "CLAUDE.md"
      "AGENTS.md"
    ];

    plugin = [
      "@simonwjackson/opencode-direnv"
    ];

    permission = {
      edit = "ask";
      bash = "ask";
      task = {
        "*" = "deny";
      };
      skill = {
        "*" = "deny";
      };
    };

    compaction = {
      auto = true;
      prune = true;
      reserved = 10000;
    };

    default_agent = "lead";
    agent =
      let
        mkFilePrompt = path: "file:${pkgs.writeText (baseNameOf (toString path)) (builtins.readFile path)}";
      in
      {
        build.disable = true;
        plan.disable = true;
        general.disable = true;
        explore.disable = true;
        scout.disable = true;

        lead = {
          description = "Clarify user intent, handle simple tasks, delegate specialized work, and synthesize results";
          mode = "primary";
          color = "#ffffff";
          model = "openai/gpt-5.5";
          temperature = 0.1;
          permission = {
            edit = "ask";
            bash = "ask";
            task = {
              "*" = "deny";
              architect = "allow";
              analyst = "allow";
              engineer = "allow";
              reviewer = "allow";
            };
            skill = {
              "*" = "deny";
              delegate = "allow";
            };
          };
          prompt = mkFilePrompt ./dotfiles/agents/lead.md;
        };

        architect = {
          description = "Break down tasks and plan implementation steps";
          mode = "subagent";
          color = "#fc9e32";
          model = "opencode-go/kimi-k2.6";
          temperature = 0.25;
          # thinking = true;
          # plan = true;
          permission = {
            edit = "deny";
            bash = "deny";
            task = {
              "*" = "deny";
            };
            skill = {
              "*" = "deny";
            };
          };
          prompt = mkFilePrompt ./dotfiles/agents/architect.md;
        };

        analyst = {
          description = "Inspect codebases, analyze findings, and explore alternative approaches";
          mode = "subagent";
          color = "#e056fd";
          model = "opencode-go/qwen3.6-plus";
          temperature = 0.4;
          permission = {
            edit = "deny";
            bash = "deny";
            task = {
              "*" = "deny";
            };
            skill = {
              "*" = "deny";
            };
          };
          prompt = mkFilePrompt ./dotfiles/agents/analyst.md;
        };

        engineer = {
          description = "General-purpose coding agent";
          mode = "subagent";
          color = "#64f55f";
          model = "openai/gpt-5.5";
          temperature = 0.1;
          # thinking = true;
          # plan = true;
          permission = {
            edit = "ask";
            bash = "ask";
            task = {
              "*" = "deny";
            };
            skill = {
              "*" = "deny";
              tdd = "allow";
              format = "allow";
              documentation = "allow";
              lint = "allow";
              test = "allow";
            };
          };
          prompt = mkFilePrompt ./dotfiles/agents/engineer.md;
        };

        reviewer = {
          description = "Review code and provide prioritized feedback";
          mode = "subagent";
          color = "#faf443";
          model = "opencode-go/deepseek-v4-pro";
          temperature = 0.15;
          # thinking = true;
          permission = {
            edit = "deny";
            bash = "ask";
            task = {
              "*" = "deny";
            };
            skill = {
              "*" = "deny";
            };
          };
          prompt = mkFilePrompt ./dotfiles/agents/reviewer.md;
        };
      };
  };
}
