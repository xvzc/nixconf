{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
in
{

  home.file.".local/bin/git-auth".source = ./git-auth;

  programs.gh = {
    enable = true;
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
          lib.optionalAttrs pkgs.stdenv.isDarwin {
            program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            program = "${pkgs._1password-gui}/bin/op-ssh-sign";
          };
      };
    };
  };
}
