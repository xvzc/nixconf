{
  inputs,
  auth,
  pkgs,
  ...
}:
{
  wallpaper.source = "${inputs.assets}/wallpapers/shinra-kusakabe.jpg";

  programs.ssh = {
    enable = true;
    includes = [ "~/.ssh/config.d/*" ];
    matchBlocks = {
      "1password-agent" = {
        host = "*";
        match = ''exec "test -z $SSH_TTY"'';
        identityAgent = (auth._1password { inherit pkgs; }).agent;
      };

      "${auth.ssh.personal.name}.github.com" = {
        hostname = "github.com";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = "~/${auth.ssh.personal.path}";
      };

      "${auth.ssh.work.name}.github.com" = {
        hostname = "github.com";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile = "~/${auth.ssh.work.path}";
      };

      "${auth.ssh.desktop.name}" = {
        hostname = "nixos-desktop-01.tailb7f463.ts.net";
        user = "mizuki";
        forwardAgent = true;
        identitiesOnly = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
        identityFile = "~/${auth.ssh.desktop.path}";
      };
    };
  };

  home.file = {
    "${auth.ssh.personal.path}".key = auth.ssh.personal.key;
    "${auth.ssh.work.path}".key = auth.ssh.work.key;
    "${auth.ssh.desktop.path}".key = auth.ssh.desktop.key;
  };
}
