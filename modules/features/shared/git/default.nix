{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    {
      outputs,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;
      vars = import ../../../../vars.nix { inherit pkgs ctx; };
    in
    {

      home.file.".local/bin/git-auth".source = ./scripts/git-auth;

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

        extraConfig = {
          user = {
            name = "xvzc";
            email = "me@xvzc.dev";
            signingKey = "${home}/${vars.ssh.pubkeys.personal.path}";
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
              program = "${vars.ssh._1password.signer}";
            };
          };
        };
      };
    };
}
