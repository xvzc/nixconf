{
  ctx,
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  vars = import ../vars.nix { inherit pkgs ctx; };
in
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/shinra-kusakabe.jpg";

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
            IdentityAgent ${_1password.agent}

          Host ${pubkeys.work.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${pubkeys.work.path}
            IdentityAgent ${_1password.agent}

          Host ${pubkeys.desktop.name}
            HostName home.xvzc.dev
            User mizuki
            ForwardAgent yes
            IdentitiesOnly yes
            StrictHostKeyChecking no
            IdentityFile ~/${pubkeys.desktop.path}
            IdentityAgent ${_1password.agent}
        '';
    };
}
