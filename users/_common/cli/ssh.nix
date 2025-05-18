{
  outputs,
  pkgs,
  lib,
  ...
}:
let
  darwinAgent = "\"~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  linuxAgent = "~/.1password/agent.sock";
in
{
  home.file.".ssh/${outputs.pubkeys.home.name}" = {
    text = outputs.pubkeys.home.text;
  };

  home.file.".ssh/${outputs.pubkeys.pers.name}" = {
    text = outputs.pubkeys.pers.text;
  };

  home.file.".ssh/${outputs.pubkeys.work.name}" = {
    text = outputs.pubkeys.work.text;
  };

  programs.ssh = {
    enable = true;
    includes = [ "~/.ssh/config.d/*" ];
    extraConfig = ''
      Host pers.github.com
        HostName github.com
        ForwardAgent yes
        IdentitiesOnly yes
        IdentityFile ~/.ssh/pers.pub
        ${lib.optionalString pkgs.stdenv.isDarwin "IdentityAgent ${darwinAgent}"}

      Host work.github.com
        HostName github.com
        ForwardAgent yes
        IdentitiesOnly yes
        IdentityFile ~/.ssh/work.pub
        ${lib.optionalString pkgs.stdenv.isDarwin "IdentityAgent ${darwinAgent}"}

      ${lib.optionalString pkgs.stdenv.isDarwin # sshconfig
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
      }

      ${lib.optionalString pkgs.stdenv.isLinux # sshconfig
        ''
          Match Host * exec "test -z $SSH_TTY"
            IdentityAgent ${linuxAgent}
        ''
      }
    '';
  };

}
