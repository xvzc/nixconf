{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    let
      vars = import ../../../vars.nix { inherit pkgs ctx; };
      inherit (vars.ssh) pubkeys _1password;
    in
    { ... }:
    {
      home.file."${pubkeys.desktop.path}" = {
        text = pubkeys.desktop.text;
      };

      home.file."${pubkeys.personal.path}" = {
        text = pubkeys.personal.text;
      };

      home.file."${pubkeys.work.path}" = {
        text = pubkeys.work.text;
      };

      home.file.".ssh/config".text = # sshconfig
        ''
          Include ~/.ssh/config.d/*

          Host ${pubkeys.personal.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${pubkeys.personal.path}
            ${lib.optionalString pkgs.stdenv.isDarwin "IdentityAgent ${vars.ssh._1password.agent}"}

          Host ${pubkeys.work.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${pubkeys.work.path}
            ${lib.optionalString pkgs.stdenv.isDarwin "IdentityAgent ${vars.ssh._1password.agent}"}

          ${lib.optionalString pkgs.stdenv.isDarwin # sshconfig
            ''
              Host ${pubkeys.desktop.name}
                HostName ${pubkeys.desktop.name}.xvzc.dev
                User mizuki
                ForwardAgent yes
                IdentitiesOnly yes
                StrictHostKeyChecking no
                IdentityFile ~/${pubkeys.desktop.path}
                IdentityAgent ${_1password.agent}
            ''
          }

          ${lib.optionalString pkgs.stdenv.isLinux # sshconfig
            ''
              Match Host * exec "test -z $SSH_TTY"
                IdentityAgent ${_1password.agent}
            ''
          }
        '';
    };
}
