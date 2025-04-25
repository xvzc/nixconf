{
  lib,
  ...
}:
{
  enable = true;
  enableZshIntegration = true;
  settings = {
    format = lib.concatStrings [
      "$directory"
      "$python"
      "$git_branch"
      "\${custom.git_dirty}"
      "$git_status"
      "$cmd_duration"
      "$line_break"
      "$hostname"
      "$character"
    ];

    directory = {
      format = "[$path]($style)";
      style = "bold blue";
      home_symbol = "~";
      truncate_to_repo = false;
      truncation_length = 0;
    };

    python = {
      format = "( [\\($virtualenv\\)](bold black))";
      detect_files = [];
    };

    git_branch = {
      format = "( [$branch](bold cyan))";
    };

    custom.git_dirty = {
      when = "[[ $(git status --porcelain) != '' ]]";
      format = "[*](red)";
    };

    git_status = {
      format = "( [$ahead_behind]($style))";
      ahead = "[⇡](cyan)";
      behind = "[⇣](cyan)";
      diverged = "[⇣⇡](cyan)";
    };

    cmd_duration = {
      format = "( [$duration](bold yellow))";
    };

    hostname = {
      ssh_only = true;
      format = "[$hostname](bold black) ";
    };

    character = {
      success_symbol = "[❯](bold purple)";
      error_symbol = "[❯](bold red)";
      vimcmd_symbol = "[❮](bold purple)";
      vimcmd_replace_one_symbol = "[❮](bold purple)";
      vimcmd_replace_symbol = "[❮](bold purple)";
      vimcmd_visual_symbol = "[❮](bold purple)";
    };
  };
}
