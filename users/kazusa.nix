{
  inputs,
  osConfig,
  ...
}:
{
  wallpaper.source = "${inputs.assets}/wallpapers/shinra-kusakabe.jpg";

  home.file =
    let
      inherit (osConfig.vars) ssh _1password;
    in
    {
      "${ssh.pubkeys.xvzc.path}".text = ssh.pubkeys.xvzc.text;
      "${ssh.pubkeys.work.path}".text = ssh.pubkeys.work.text;
      "${ssh.pubkeys.desktop.path}".text = ssh.pubkeys.desktop.text;

      ".ssh/config".text =
        # sshconfig
        ''
          Include ~/.ssh/config.d/*

          Host ${ssh.pubkeys.xvzc.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${ssh.pubkeys.xvzc.path}
            IdentityAgent ${_1password.agent}

          Host ${ssh.pubkeys.work.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${ssh.pubkeys.work.path}
            IdentityAgent ${_1password.agent}

          Host ${ssh.pubkeys.desktop.name}
            HostName nixos-desktop-01.tailb7f463.ts.net
            User mizuki
            ForwardAgent yes
            IdentitiesOnly yes
            StrictHostKeyChecking no
            IdentityFile ~/${ssh.pubkeys.desktop.path}
            IdentityAgent ${_1password.agent}
        '';
    };
}
