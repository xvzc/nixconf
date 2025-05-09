{
  pkgs,
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

  xdg.configFile."tmux/projects" = {
    source = ./projects;
    recursive = true;
  };

  programs.zsh.sessionVariables = {
    KEYTIMEOUT = 1; # Remove ESC delay
    TMUXINATOR_CONFIG = "$HOME/.config/tmux/projects";
  };

  programs.zsh.shellAliases = {
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
        plugin = pkgs.unstable.tmuxPlugins.catppuccin;
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

    extraConfig = # tmux
      ''
        # ┌─────────┐ 
        # │ OPTIONS │ 
        # └─────────┘ 
        set -sa terminal-features ",wezterm:RGB"
        set -gq allow-passthrough "on"
        set -g  focus-events      "on"
        set -g  renumber-windows  "on"
        setw -g automatic-rename  "on"
        set -g  set-titles        "on"
        set -g  status-position   "top"
        set -s  set-clipboard     "on"
        # setw -g monitor-activity  on

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

        bind -r C-n next-window
        bind -r C-p previous-window

        bind - split-window -v -c "#{pane_current_path}"
        bind _ split-window -h -c "#{pane_current_path}"
        bind c new-window      -c "#{pane_current_path}"

        bind f resize-pane -Z;
        bind v run-shell   -b "~/.config/tmux/scripts/new-nvim-buffer"
        bind i run-shell   -b "~/.config/tmux/scripts/new-session"
        bind s run-shell   -b "~/.config/tmux/scripts/switch-session"
        bind ! setw        synchronize-panes

        bind-key -n F12 if-shell -F '#{==:#{session_name},scratch}' {
          detach-client
        } {
          display-popup -w 60% -h 70% -E -B "tmux new -A -s scratch"
        } 

        # ┌────────┐ 
        # │ STYLES │ 
        # └────────┘ 
        # Configure Tmux
        set -g status-position "top"
        set -g status-style    "bg=default"
        set -g status-justify "absolute-centre"

        # status left look and feel
        set -g status-interval    1
        set -g status-left-length 100
        set -g status-left        ""
        set -ga status-left       "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_bg},bold]  #S },#{#[bg=default,fg=#{@thm_green}]  #S }}"
        set -ga status-left       "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
        set -ga status-left       "#[bg=default,fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"
        set -ga status-left       "#[bg=default,fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"

        # status right look and feel
        set -g  status-right-length 100
        set -g  status-right        ""
        set -ga status-right        "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
        set -ga status-right        "#[bg=default,fg=#{@thm_maroon}]  #{pane_current_command} "

        # window look and feel
        set -wg automatic-rename        "on"
        # set -g  automatic-rename-format "Window"

        set -ga status-right                "#[bg=default,fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
        # set -g  window-status-format         " #I #{?window_end_flag,#{#[bg=default,fg=#{@thm_overlay_0},none]│},}"
        set -g window-status-format " #I#{?#{!=:#{window_name},Window},: #W,} "
        set -g  window-status-style          "bg=default,fg=#{@thm_rosewater}"
        set -g  window-status-last-style     "bg=default,fg=#{@thm_peach}"
        set -g  window-status-activity-style "bg=#{@thm_red},fg=#{@thm_bg}"
        set -g  window-status-bell-style     "bg=#{@thm_red},fg=#{@thm_bg},bold"
        set -gF window-status-separator     "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}]│"

        # set -g  window-status-current-format "#[bg=#{@thm_peach},fg=#{@thm_bg},bold] #I #{?window_end_flag,#{#[bg=default,fg=#{@thm_overlay_0},none]│},}"
        set -g window-status-current-format " #I#{?#{!=:#{window_name},Window},: #W,} "
        set -g window-status-current-style "bg=#{@thm_peach},fg=#{@thm_bg},bold"

        # Border
        set  -g pane-active-border-style     bg=default,fg=#ddbaf7
        set  -g pane-border-style            fg=#6a5b75

        if-shell "test -e ${mutableConfig}" "source-file ${mutableConfig}"
      '';
  };
}
