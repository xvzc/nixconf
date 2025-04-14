{

  git = {
    enable = true;
    userName = "xvzc";
    userEmail = "dev.kwanghoo@gmail.com";
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      pull.rebase = true;
    };
    includes = [
      {
        condition = "gitdir:~/_work/";
        path = "~/.gitconfig-work";
      }
    ];
  };

  starship = {
    enable = true;
  };

  neovim = {
    enable = true;
  };

  vim = {
    enable = true;
  };

  wezterm = {
    enable = true;
  };

  ssh = {
    enable = true;
  };

  tmux = {
    enable = true;
  };
}
