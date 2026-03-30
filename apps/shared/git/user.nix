{
  osConfig,
  config,
  pkgs,
  ...
}:
let
  inherit (osConfig) vars;
  home = config.home.homeDirectory;
in
{
  home.file.".local/bin/git-auth".source = ./_files/scripts/git-auth;

  programs.gh = {
    enable = true;
    package = pkgs.gh;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    includes = [
      {
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work";
      }
    ];

    hooks = {
      prepare-commit-msg = ./_files/hooks/prepare-commit-msg;
    };

    settings = {
      user = {
        name = "xvzc";
        email = "me@xvzc.dev";
        signingKey = "${home}/${vars.ssh.pubkeys.xvzc.path}";
      };

      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      pull.rebase = true;
      push.default = "current";
      init.defaultBranch = "main";

      tag.gpgSign = true;
      commit.gpgSign = true;

      gpg = {
        format = "ssh";
        ssh = {
          program = "${vars._1password.signer}";
        };
      };
      url = {
        "git@xvzc.github.com:xvzc" = {
          insteadOf = "git@github.com:xvzc";
        };
      };
    };
  };
}
