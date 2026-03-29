{
  inputs,
  osConfig,
  ...
}:
let
  inherit (osConfig) vars;
in
{
  wallpaper.source = "${inputs.assets}/wallpapers/duckgirl-darkmode.jpg";

  home.file = {
    "${vars.ssh.pubkeys.personal.path}".text = vars.ssh.pubkeys.personal.text;
    "${vars.ssh.pubkeys.work.path}".text = vars.ssh.pubkeys.work.text;
    "${vars.ssh.pubkeys.desktop.path}".text = vars.ssh.pubkeys.desktop.text;
    ".ssh/config".text =
      # sshconfig
      ''

        Include ~/.ssh/config.d/*

        Host ${vars.ssh.pubkeys.personal.name}.github.com
          HostName github.com
          ForwardAgent yes
          IdentitiesOnly yes
          IdentityFile ~/${vars.ssh.pubkeys.personal.path}

        Host ${vars.ssh.pubkeys.work.name}.github.com
          HostName github.com
          ForwardAgent yes
          IdentitiesOnly yes
          IdentityFile ~/${vars.ssh.pubkeys.work.path}


        # Add the option below when "test -z $SSH_TTY" evaluates to true
        # (i.e., when the string length of $SSH_TTY is zero),
        # indicating that the current shell is not running in an SSH session.
        Match Host * exec "test -z $SSH_TTY"
          IdentityAgent ${vars._1password.agent}
      '';
  };
}
