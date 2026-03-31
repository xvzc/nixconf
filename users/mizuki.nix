{
  inputs,
  auth,
  pkgs,
  ...
}:
{
  wallpaper.source = "${inputs.assets}/wallpapers/duckgirl-darkmode.jpg";

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
    };
  };

  home.file = {
    "${auth.ssh.personal.path}".text = auth.ssh.personal.key;
    "${auth.ssh.work.path}".text = auth.ssh.work.key;
    "${auth.ssh.desktop.path}".text = auth.ssh.desktop.key;
  };
}
