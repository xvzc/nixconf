{
  pkgs,
  auth,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/config.d/*" ];

    settings = {
      "Match exec \"test -z $SSH_TTY\"" = {
        identityAgent = (auth._1password { inherit pkgs; }).agent;
      };

      "Host ${auth.ssh.personal.name}.github.com" = {
        hostname = "github.com";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = "~/${auth.ssh.personal.path}";
      };

      "Host ${auth.ssh.work.name}.github.com" = {
        hostname = "github.com";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = "~/${auth.ssh.work.path}";
      };
    };
  };

  home.file = {
    "${auth.ssh.personal.path}".text = auth.ssh.personal.key;
    "${auth.ssh.work.path}".text = auth.ssh.work.key;
  };
}
