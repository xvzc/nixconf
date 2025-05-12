{
  ...
}:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      "fg" = "#e0dada";
      "fg+" = "#fbdada";
      "bg" = "#313f54";
      "bg+" = "#313f54";
      "hl" = "#6bc9e1";
      "hl+" = "#33eaff";
      "info" = "#aaaa84";
      "marker" = "#4fe62d";
      "prompt" = "#f32d2d";
      "spinner" = "#fdf905";
      "pointer" = "#fdf905";
      "header" = "#87afaf";
      "border" = "#648f66";
      "preview-bg" = "#1f2c3d";
      "label" = "#aeaeae";
      "query" = "#d9d9d9";
    };

    defaultCommand = "fd --type f --no-ignore --hidden --follow --exclude .git";

    defaultOptions = [
      "--reverse"
      "--info='right'"
      "--height=40%"
      "--border='bold'"
      "--border-label=''"
      "--preview-window='border-bold'"
      "--prompt='> '"
      "--marker='▪'"
      "--pointer='●'"
      "--separator='─'"
      "--scrollbar='┃'"
    ];

    fileWidgetCommand = "fd --type f --hidden --no-ignore";
    fileWidgetOptions = [
      "--preview 'bat {}'"
    ];

    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];

    changeDirWidgetCommand = "fd --type d --hidden";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];

    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [
        "-p80%,60%"
      ];
    };
  };

  programs.zsh.profileExtra = # sh
    ''
      function fvi() {
        out=$( \
          fd -L --type f --hidden --relative-path --follow --exclude .git $1 \
            | fzf \
            --preview 'bat --style=numbers --color=always --line-range :500 {}' \
            --query=$1 \
        )

        [[ ! -z $out ]] && nvim $out
      }

      function fcd() {
        out=$( \
          fd -L --type d --hidden --relative-path \
            | fzf \
            --preview='eza --tree --only-dirs {}' \
            --query=$1 \
        )

        [[ ! -z $out ]] && cd $out
      }
    '';
}
