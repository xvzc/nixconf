{
  pkgs,
  lib,
  ...
}:
{
  xdg.configFile."tmux/scripts" = {
    source = ./dotfiles/scripts;
    recursive = true;
  };

  home.file.".config/tmux/projects.json".text = builtins.toJSON {
    lookupDirs = [
      "~/personal"
    ];

    named = {
      main = {
        root = "~";
      };

      nixconf = {
        root = "~/nixconf";
      };

      nvim = {
        root = "~/.config/nvim";
        env = {
          NVIM_APPNAME = "nvim";
        };
      };

      pi = {
        root = "~/.config/pi";
        env = {
          PI_CODING_AGENT_DIR = "~/.config/pi/agent";
        };
      };
    };
  };

  home.shellAliases = {
    tds = "tmux detach";
    tks = "tmux kill-session -t";
    tss = "tmux -u switch -t";
    tns = "tmux -u new -c ~ -A -s";
    tls = "tmux ls ";
  };

  programs.zsh.initContent =
    lib.mkOrder 1003 # sh
      ''
        function tis() {
          if [ -z "$1" ]; then
            ~/.config/tmux/scripts/switch-session main
          else
            ~/.config/tmux/scripts/switch-session $1
          fi
        }
      '';

  programs.tmux = {
    enable = true;
    package = pkgs.unstable.tmux;
    tmuxinator.enable = true;

    prefix = "C-a";
    terminal = "tmux-256color";
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
        extraConfig =
          # tmux
          ''
            set -g @catppuccin_flavor "macchiato"
            set -g @catppuccin_status_background "none"
            set -g @catppuccin_window_status_style "none"
            set -g @catppuccin_pane_status_enabled "off"
            set -g @catppuccin_pane_border_status "off"
          '';
      }
    ];

    extraConfig = builtins.readFile ./dotfiles/tmux.extra.conf;
  };
}
