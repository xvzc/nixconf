{
  config,
  lib,
  ctx,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
in
{
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
      signingKey = "${home}/.ssh/personal.pub";
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
      ssh =
        lib.optionalAttrs ctx.isDarwin {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        }
        // lib.optionalAttrs ctx.isLinux {
          program = "${pkgs._1password-gui}/bin/op-ssh-sign";
        };
    };
  };
}
