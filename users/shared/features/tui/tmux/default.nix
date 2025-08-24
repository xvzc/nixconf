{
  pkgs,
  ...
}:
{
  xdg.configFile."tmux/scripts" = {
    source = ./scripts;
    recursive = true;
  };

  xdg.configFile."tmux/projects" = {
    source = ./projects;
    recursive = true;
  };

  home.sessionVariables = {
    TMUXINATOR_CONFIG = "$HOME/.config/tmux/projects";
  };

  home.shellAliases = {
    tds = "tmux detach";
    tks = "tmux kill-session -t";
    tss = "tmux -u switch -t";
    tns = "tmux -u new -c ~ -A -s";
    tls = "tmux ls";
    tis = "tmuxinator start";
    til = "tmuxinator ls";
  };

  programs.tmux = {
    enable = true;
    tmuxinator.enable = true;

    prefix = "C-a";
    terminal = "wezterm";
    baseIndex = 1;
    disableConfirmationPrompt = false;
    escapeTime = 10; # Default
    historyLimit = 5000;
    keyMode = "vi";
    mouse = true;
    customPaneNavigationAndResize = true;
    resizeAmount = 1;
    sensibleOnTop = false;

    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = # tmux
          ''
            set -g @catppuccin_flavor "macchiato"
            set -g @catppuccin_status_background "none"
            set -g @catppuccin_window_status_style "none"
            set -g @catppuccin_pane_status_enabled "off"
            set -g @catppuccin_pane_border_status "off"
          '';
      }
    ];

    extraConfig = builtins.readFile ./tmux.extra.conf;
  };
}
