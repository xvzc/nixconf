{
  auth,
  config,
  pkgs,
  ...
}:
let
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
        signingKey = "${home}/${auth.ssh.personal.path}";
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
          program = (auth._1password { inherit pkgs; }).signer;
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
          auth.ssh.personal.name
          auth.ssh.work.name
        ];
    };
  };
}
