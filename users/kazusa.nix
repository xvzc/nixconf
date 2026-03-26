{
  inputs,
  osConfig,
  ...
}:
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/shinra-kusakabe.jpg";

  home.file =
    let
      inherit (osConfig.vars) ssh _1password;
    in
    {
      "${ssh.pubkeys.personal.path}".text = ssh.pubkeys.personal.text;
      "${ssh.pubkeys.work.path}".text = ssh.pubkeys.work.text;
      "${ssh.pubkeys.desktop.path}".text = ssh.pubkeys.desktop.text;

      ".ssh/config".text =
        # sshconfig
        ''
          Include ~/.ssh/config.d/*

          Host ${ssh.pubkeys.personal.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${ssh.pubkeys.personal.path}
            IdentityAgent ${_1password.agent}

          Host ${ssh.pubkeys.work.name}.github.com
            HostName github.com
            ForwardAgent yes
            IdentitiesOnly yes
            IdentityFile ~/${ssh.pubkeys.work.path}
            IdentityAgent ${_1password.agent}

          Host ${ssh.pubkeys.desktop.name}
            HostName home.xvzc.dev
            User mizuki
            ForwardAgent yes
            IdentitiesOnly yes
            StrictHostKeyChecking no
            IdentityFile ~/${ssh.pubkeys.desktop.path}
            IdentityAgent ${_1password.agent}
        '';
    };
}
