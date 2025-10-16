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
      ".ssh/config".text = # sshconfig
        ''

          Include ~/.ssh/config.d/*

          Host ${pubkeys.personal.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${pubkeys.personal.path}
            # IdentityAgent ${vars.ssh._1password.agent}

          Host ${pubkeys.work.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${pubkeys.work.path}
            # IdentityAgent ${vars.ssh._1password.agent}


          Match Host * exec "test -z $SSH_TTY"
            IdentityAgent ${_1password.agent}

        '';

    };
}
