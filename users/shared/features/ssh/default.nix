{
  pkgs,
  lib,
  ...
}:
let
  darwinAgent = "\"~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  linuxAgent = "~/.1password/agent.sock";
in
{
  home.file.".ssh/home.pub" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIOn17UKMSvSOCQ6/XH+sqBjbpSbu+r0ECJEnVZ7niy";
  };

  home.file.".ssh/personal.pub" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZZ3IHZk+M07W5NhhKWLq0wmoFQ+xi4Mk8isnJcjVe5";
  };

  home.file.".ssh/work.pub" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtHXAUu74FYAyhBgsPTzvofhr0YDQ1SDWczpupcUjdc";
  };

  programs.ssh = {
    enable = true;
    includes = [ "~/.ssh/config.d/*" ];
    extraConfig = # sshconfig
      ''
        Host personal.github.com
          HostName github.com
          ForwardAgent yes
          IdentitiesOnly yes
          IdentityFile ~/.ssh/personal.pub
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
