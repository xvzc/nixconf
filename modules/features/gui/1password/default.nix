{
  pkgs,
  lib,
  ...
}:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      _1password-cli = final.mv.tip._1password-cli;
      _1password-gui =
        if pkgs.stdenv.isDarwin then
          final.mv.tip._1password-gui
        else
          final.mv.tip._1password-gui.overrideAttrs (old: {
            postInstall = ''
              ${old.postInstall or ""}
              wrapProgram $out/share/1password/1password \
                --add-flags "--ozone-platform=x11"
            '';
          });
    })
  ];

  programs._1password-gui.enable = true;
  programs._1password.enable = true;

  hm.users.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;

      # Linux signer. op-ssh-sign uses SSH_AUTH_SOCK only when SSH_TTY is set
      # too, but inside tmux SSH_TTY comes from whichever shell started the
      # server. Set or clear it by the same rule as the ssh config below, so
      # signing follows the live agent like ssh does.
      sign = pkgs.writeShellScript "1password-sign" ''
        if [ -S "''${SSH_AUTH_SOCK:-}" ]; then
          export SSH_TTY="''${SSH_TTY:-/dev/tty}"
        else
          unset SSH_TTY
        fi
        exec ${pkgs._1password-gui}/bin/op-ssh-sign "$@"
      '';
    in
    {
      # Fixed paths on both OSes, so ssh, git and jj do not branch.
      home.file = {
        ".ssh/1password-agent.sock".source = config.lib.file.mkOutOfStoreSymlink (
          if pkgs.stdenv.isDarwin then
            "${home}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          else
            "${home}/.1password/agent.sock"
        );
        ".ssh/1password-sign".source =
          if pkgs.stdenv.isDarwin then
            "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          else
            sign;
      };

      # Which agent ssh uses.
      #   Darwin: 1Password, except in an SSH session (it runs no SSH server).
      #   Linux:  SSH_AUTH_SOCK when it is a live socket, otherwise 1Password.
      #           SSH_AUTH_SOCK is only ever a forwarded agent: set by sshd, or
      #           tmux's link to the focused client's (see the tmux module).
      #           `test -S` follows the link, so a removed or dead one counts
      #           as none.
      programs.ssh.settings =
        if pkgs.stdenv.isDarwin then
          {
            "Match exec \"test -z $SSH_TTY\"".identityAgent = "~/.ssh/1password-agent.sock";
          }
        else
          {
            "Match exec \"test ! -S \\\"$SSH_AUTH_SOCK\\\"\"".identityAgent =
              "~/.ssh/1password-agent.sock";
          };

      xdg.configFile."1Password/ssh/agent.toml".text =
        # toml
        ''
          [[ssh-keys]]
          vault = "Personal"

          [[ssh-keys]]
          vault = "Work"
        '';
    };
}
