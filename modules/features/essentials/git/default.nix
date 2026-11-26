{ ... }:
{
  hm.users.default =
    {
      pub,
      config,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;
    in
    {
      home.packages = [
        pkgs.commitlint
        pkgs.difftastic
      ];
      home.file.".local/bin/git-auth".source = ./dotfiles/scripts/git-auth;

      programs.gh = {
        enable = true;
        package = pkgs.mv.tip.gh;
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
        };
      };

      programs.jujutsu = {
        enable = true;
        package = pkgs.mv.tip.jujutsu;
        settings = {
          user = {
            name = "xvzc";
            email = "me@xvzc.dev";
          };

          signing = {
            behavior = "drop";
            backend = "ssh";
            key = "${home}/${pub.git.xvzc.path}";
            backends.ssh.program = "${home}/.ssh/1password-sign";
          };
          revsets.git-sign-on-push = "~signed() & mine()";

          ui = {
            editor = "nvim";
            default-command = "log";
            diff-formatter = [
              "${pkgs.difftastic}/bin/difft"
              "--color=always"
              "$left"
              "$right"
            ];
          };

          revset-aliases."closest_bookmark(to)" = "heads(::to & bookmarks())";

          aliases = {
            tug = [
              "bookmark"
              "move"
              "--from"
              "closest_bookmark(@-)"
              "--to"
              "@-"
            ];
          };
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
          commit-msg = pkgs.writeShellScript "commit-msg" ''
            exec ${pkgs.commitlint}/bin/commitlint \
              --extends @commitlint/config-conventional \
              --edit "$1"
          '';
        };

        settings = {
          user = {
            name = "xvzc";
            email = "me@xvzc.dev";
            signingKey = "${home}/${pub.git.xvzc.path}";
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
              program = "${home}/.ssh/1password-sign";
            };
          };
          url =
            let
              mkGithubUrlMappings =
                names:
                builtins.listToAttrs (
                  map (name: {
                    name = "git@${name}.github.com:${name}";
                    value = {
                      insteadOf = "git@github.com:${name}";
                    };
                  }) names
                );
            in
            mkGithubUrlMappings (builtins.attrNames pub.git);
        };
      };
    };
}
