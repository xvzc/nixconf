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
  ];
  home.file.".local/bin/git-auth".source = ./dotfiles/scripts/git-auth;

  programs.gh = {
    enable = true;
    package = pkgs.unstable.gh;
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
        signingKey = "${home}/${pub.ssh.personal.path}";
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
          program = (pub._1password { inherit pkgs; }).signer;
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
        mkGithubUrlMappings [
          pub.ssh.personal.name
          pub.ssh.work.name
        ];
    };
  };
}
