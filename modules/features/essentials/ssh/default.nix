{ ... }:
{
  hm.users.default =
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
            identityAgent = "~/.ssh/1password-agent.sock";
          };

          "Host ${pub.personal.name}.github.com" = {
            hostname = "github.com";
            forwardAgent = true;
            identitiesOnly = true;
            identityFile = "~/${pub.personal.path}";
          };

          "Host ${pub.work.name}.github.com" = {
            hostname = "github.com";
            forwardAgent = true;
            identitiesOnly = true;
            identityFile = "~/${pub.work.path}";
          };
        };
      };

      home.file = {
        "${pub.personal.path}".text = pub.personal.key;
        "${pub.work.path}".text = pub.work.key;
      };
    };
}
