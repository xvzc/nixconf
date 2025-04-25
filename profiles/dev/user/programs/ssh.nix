{
  ctx,
  lib,
  ...
}:
let
  darwinAgent = "\"~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  linuxAgent = "~/.1password/agent.sock";
in
{
  enable = true;
  includes = [ "~/.ssh/config.d/*" ];
  extraConfig = # sshconfig
    ''
      Host personal.github.com
        HostName github.com
        ForwardAgent yes
        IdentitiesOnly yes
        IdentityFile ~/.ssh/personal.pub
        ${if ctx.isDarwin then "IdentityAgent ${darwinAgent}" else ""}

      Host work.github.com
        HostName github.com
        ForwardAgent yes
        IdentitiesOnly yes
        IdentityFile ~/.ssh/work.pub
        ${if ctx.isDarwin then "IdentityAgent ${darwinAgent}" else ""}

      ${
        if ctx.isDarwin then # sshconfig
          ''
            Host home
              HostName home.xvzc.dev
              User mario
              ForwardAgent yes
              IdentitiesOnly yes
              StrictHostKeyChecking no
              IdentityFile ~/.ssh/home.pub
              IdentityAgent ${darwinAgent}
          ''
        else
          ""
      }

      ${
        if ctx.isLinux then # sshconfig
          ''
            Match Host * exec "test -z $SSH_TTY"
              IdentityAgent ${linuxAgent}
          ''
        else
          ""
      }
    '';
}
