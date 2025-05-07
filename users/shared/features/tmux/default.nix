{
  ...
}:
let
  mutableConfig = "~/.config/tmux/tmux.mutable.conf";
in
{
  xdg.configFile."tmux/scripts" = {
    source = ./scripts;
    recursive = true;
  };

  programs.zsh.shellAliases = {
    tas = "tmux -u attach-session -t";
    tds = "tmux detach";
    tks = "tmux kill-session -t";
    tss = "tmux -u switch -t";
    tns = "tmux -u new -c ~ -s";
    tls = "tmux ls";
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    disableConfirmationPrompt = false;
    escapeTime = 10; # Default
    historyLimit = 5000;
    keyMode = "vi";
    mouse = true;
    customPaneNavigationAndResize = true;
    resizeAmount = 1;
    sensibleOnTop = false;

    extraConfig = # tmux
      ''
        # ┌─────────┐ 
        # │ OPTIONS │ 
        # └─────────┘ 
        set -g  default-terminal  "wezterm"
        set -sa terminal-features ",wezterm:RGB"
        set -gq allow-passthrough on
        set -g  focus-events      on
        set -g  renumber-windows  on
        setw -g automatic-rename  on
        set -g  set-titles        on
        set -g  status-position   top
        set -s  set-clipboard     on
        setw -g monitor-activity  on

        # ┌─────────────┐ 
        # │ KEYBINDINGS │ 
        # └─────────────┘ 
        unbind    n
        unbind    s
        unbind    p
        unbind    C-c
        unbind -T copy-mode-vi Enter

        bind -n WheelDownPane select-pane -t= \; send-keys -M
        bind -n C-WheelUpPane select-pane -t= \; copy-mode -e \; send-keys -M
        bind -n WheelUpPane \
          if-shell -Ft = "#{mouse_any_flag}" \
          "send-keys -M" \
          "if -Ft = '#{pane_in_mode}' 'send -M' 'select-pane -t=; copy-mode -e; send -M'"

        bind -T copy-mode-vi    C-WheelUpPane   send -X halfpage-up
        bind -T copy-mode-vi    C-WheelDownPane send -X halfpage-down
        bind -T copy-mode-emacs C-WheelUpPane   send -X halfpage-up
        bind -T copy-mode-emacs C-WheelDownPane send -X halfpage-down
        bind -T copy-mode-vi    v               send -X begin-selection
        bind -T copy-mode-vi    y               send -X copy-selection-and-cancel
        bind -T copy-mode-vi    V               send -X select-line
        bind -T copy-mode-vi    escape          send -X cancel

        bind -r f   resize-pane -Z; # Maximize current pane
        bind -r C-n next-window
        bind -r C-p previous-window

        bind - split-window -v -c "$HOME"
        bind _ split-window -h -c "$HOME"

        bind c run-shell -b "~/.config/tmux/scripts/new-window"
        bind v run-shell -b "~/.config/tmux/scripts/new-nvim-buffer"
        bind i run-shell -b "~/.config/tmux/scripts/new-session"
        bind s run-shell -b "~/.config/tmux/scripts/switch-session"
        bind ! setw synchronize-panes;

        # ┌────────┐ 
        # │ STYLES │ 
        # └────────┘ 
        set  -g status-style                 bg=default

        # Status bar
        set  -g status-left-length           60
        set  -g status-left                  "#[fg=black, bg=green] #S #[default] "
        set  -g status-right                 "#[fg=white,bg=default]"

        # Inactive windows
        set  -g window-status-style          fg=colour244,bg=default
        set  -g window-status-format         "[#I] #W "
        setw -g window-status-separator      "#[fg=white]|"

        # Active windows
        set  -g window-status-current-style  fg=black,bg=colour136
        set  -g window-status-current-format "[#I] #W "

        # Border
        set  -g pane-active-border-style     bg=default,fg=#ddbaf7
        set  -g pane-border-style            fg=#6a5b75

        if-shell "test -e ${mutableConfig}" "source-file ${mutableConfig}"
      '';
  };

}
