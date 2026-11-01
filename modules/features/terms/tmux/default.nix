{ ctx, lib, ... }:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  # nixpkgs.overlays = lib.mkBefore [
  #   (final: prev: {
  #     tmux = prev.tmux.overrideAttrs (oldAttrs: {
  #       src = prev.fetchFromGitHub {
  #         owner = "tmux";
  #         repo = "tmux";
  #         rev = "449f255f3ef0167c6d226148cdaabac70686dde9";
  #         sha256 = "sha256-tBh84C7Kt3qjV4oZOcL05dVvBNMFtiCF45uogZvYxiY=";
  #       };
  #     });
  #     tmuxPlugins.catppuccin = final.mv.tip.tmuxPlugins.catppuccin;
  #   })
  # ];

  home-manager.users.${ctx.user} =
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

            # Records the tty of the shell per pane for switch-session. A shell in
            # nvim's :terminal is skipped so that it keeps the value of nvim's shell.
            autoload -Uz add-zsh-hook
            function _tmux_pane_tty_precmd() {
              local last_status=$?
              if [[ -n $TMUX && -n $TMUX_PANE && -z $NVIM ]]; then
                command tmux set -p -t "$TMUX_PANE" -- @pane_tty "$TTY" >/dev/null 2>&1
              fi
              return $last_status
            }
            add-zsh-hook precmd _tmux_pane_tty_precmd
          '';

      programs.tmux = {
        enable = true;
        package = pkgs.mv.tip.tmux;
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
    };
}
