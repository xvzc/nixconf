{config, ...}: let
  home = config.home.homeDirectory;
in {
  git = {
    enable = true;
    lfs.enable = true;
    includes = [
      {
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work";
      }
    ];

    extraConfig = {
      user = {
        name = "xvzc";
        email = "dev.kwanghoo@gmail.com";
        signingKey = "${home}/.ssh/xvzc.pub";
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

      gpg.format = "ssh";
      gpg.ssh.program = "${home}/.1password/op-ssh-sign";
    };
  };
}
