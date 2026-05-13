{ pkgs, lib, ... }:
{
  # ┏━━━━━━━━━━━━━┓
  # ┃ CLAUDE CODE ┃
  # ┗━━━━━━━━━━━━━┛
  home.file.".claude/rules" = {
    source = ./dotfiles/rules;
    recursive = true;
  };

  home.file.".claude/commands" = {
    source = ./dotfiles/commands;
    recursive = true;
  };

  home.file.".claude/skills" = {
    source = ./dotfiles/skills;
    recursive = true;
  };

  home.file.".claude/CLAUDE.md" = {
    source = ./dotfiles/AGENTS.md;
    recursive = true;
  };

  home.file.".claude/settings.json" = {
    force = true;
  };

  programs.zsh.sessionVariables = {
    CLAUDE_CODE_NO_FLICKER = 1;
  };

  programs.claude-code = {
    enable = true;
    settings = {
      model = "sonnet";
      defaultShell = "bash";
      includeCoAuthoredBy = false;
    };
  };
}
