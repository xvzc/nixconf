{ pkgs, lib, ... }:
{
  home.file.".claude/rules" = {
    source = ./dotfiles/rules;
    recursive = true;
  };

  programs.bash = {
    enable = true;
    bashrcExtra = # sh
      ''
        if command -v ${pkgs.bash}/bin/direnv >/dev/null 2>&1; then
          if [ -n "$CLAUDECODE" ]; then
            eval "$(direnv hook bash)"
            eval "$(DIRENV_LOG_FORMAT= ${pkgs.bash}/bin/direnv export bash)"
          fi
        fi
      '';
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
