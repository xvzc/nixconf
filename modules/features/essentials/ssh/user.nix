{
  pkgs,
  pub,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/config.d/*" ];

    settings = {
      "Match exec \"test -z $SSH_TTY\"" = {
        identityAgent = (pub._1password { inherit pkgs; }).agent;
      };

      "Host ${pub.ssh.personal.name}.github.com" = {
        hostname = "github.com";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = "~/${pub.ssh.personal.path}";
      };

      "Host ${pub.ssh.work.name}.github.com" = {
        hostname = "github.com";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = "~/${pub.ssh.work.path}";
      };
    };
  };

  home.file = {
    "${pub.ssh.personal.path}".text = pub.ssh.personal.key;
    "${pub.ssh.work.path}".text = pub.ssh.work.key;
  };
}
