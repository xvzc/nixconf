{
  inputs,
  pkgs,
  ctx,
  lib,
  ...
}:
let
  vars = import ../vars.nix { inherit pkgs ctx; };
in
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/duckgirl-darkmode.jpg";

  home.file =
    let
      inherit (vars.ssh) pubkeys _1password;
    in
    {
      "${pubkeys.personal.path}".text = pubkeys.personal.text;
      "${pubkeys.work.path}".text = pubkeys.work.text;
      "${pubkeys.desktop.path}".text = pubkeys.desktop.text;
      ".ssh/config".text =
        # sshconfig
        ''

          Include ~/.ssh/config.d/*

          Host ${pubkeys.personal.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${pubkeys.personal.path}

          Host ${pubkeys.work.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${pubkeys.work.path}


          # Add the option below when "test -z $SSH_TTY" evaluates to true
          # (i.e., when the string length of $SSH_TTY is zero),
          # indicating that the current shell is not running in an SSH session.
          Match Host * exec "test -z $SSH_TTY"
            IdentityAgent ${_1password.agent}
        '';
    };
}
