{
  outputs,
  pkgs,
  lib,
  ...
}:
let
  darwinAgent = "\"~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  linuxAgent = "~/.1password/agent.sock";
  pubkeys = import ../../../vars/pubkeys.nix;
in
{
  home.file."${pubkeys.home.path}" = {
    text = pubkeys.home.text;
  };

  home.file."${pubkeys.pers.path}" = {
    text = pubkeys.pers.text;
  };

  home.file."${pubkeys.work.path}" = {
    text = pubkeys.work.text;
  };

  programs.ssh = {
    enable = true;
    includes = [ "~/.ssh/config.d/*" ];
    extraConfig = ''
      Host ${pubkeys.pers.name}.github.com
        HostName github.com
        ForwardAgent yes
        IdentitiesOnly yes
        IdentityFile ~/${pubkeys.pers.path}
        ${lib.optionalString pkgs.stdenv.isDarwin "IdentityAgent ${darwinAgent}"}

      Host ${pubkeys.work.name}.github.com
        HostName github.com
        ForwardAgent yes
        IdentitiesOnly yes
        IdentityFile ~/${pubkeys.work.path}
        ${lib.optionalString pkgs.stdenv.isDarwin "IdentityAgent ${darwinAgent}"}

      ${lib.optionalString pkgs.stdenv.isDarwin # sshconfig
        ''
          Host ${pubkeys.home.name}
            HostName ${pubkeys.home.name}.xvzc.dev
            User mizuki
            ForwardAgent yes
            IdentitiesOnly yes
            StrictHostKeyChecking no
            IdentityFile ~/${pubkeys.home.path}
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
