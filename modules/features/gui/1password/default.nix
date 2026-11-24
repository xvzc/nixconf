{
  pkgs,
  ctx,
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

  home-manager.users.${ctx.user} =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;
      agent = "${home}/.ssh/1password-agent.sock";

      # Linux only: SSH_AUTH_SOCK is fixed to this link, which follows the
      # focused tmux client: its forwarded agent over SSH, otherwise 1Password.
      agentLink = "${home}/.ssh/active-agent.sock";
      agentRelink = pkgs.writeShellApplication {
        name = "agent-relink";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.gnused
          pkgs.mv.tip.openssh
          pkgs.mv.tip.tmux
        ];
        text = ''
          # Usage: agent-relink [<tmux-client-pid>]
          # Without a pid, it uses the focused tmux client, if any.
          link="${agentLink}"
          fallback="${agent}"

          # ssh-add exits 2 when it cannot reach the agent.
          alive() {
            [ -S "$1" ] || return 1
            local rc=0
            SSH_AUTH_SOCK="$1" ssh-add -l >/dev/null 2>&1 || rc=$?
            [ "$rc" -ne 2 ]
          }

          pid="''${1:-}"
          if [ -z "$pid" ]; then
            pid=$(tmux list-clients -F '#{client_pid} #{client_flags}' 2>/dev/null |
              grep -m1 'focused' | cut -d' ' -f1 || true)
          fi

          target="$fallback"
          if [ -n "$pid" ] && [ -r "/proc/$pid/environ" ]; then
            env=$(tr '\0' '\n' <"/proc/$pid/environ")
            if grep -q '^SSH_CONNECTION=' <<<"$env"; then
              # The shell replaces SSH_AUTH_SOCK with the link, and keeps the
              # forwarded socket in SSH_AUTH_SOCK_FORWARDED.
              sock=$(sed -n 's/^SSH_AUTH_SOCK_FORWARDED=//p' <<<"$env")
              [ -n "$sock" ] || sock=$(sed -n 's/^SSH_AUTH_SOCK=//p' <<<"$env")
              if [ -n "$sock" ] && [ "$sock" != "$link" ] && alive "$sock"; then
                target="$sock"
              fi
            fi
          fi

          [ "$(readlink "$link" 2>/dev/null)" = "$target" ] && exit 0
          ln -sfn "$target" "$link.tmp.$$"
          mv -T "$link.tmp.$$" "$link"
        '';
      };

      sock = if pkgs.stdenv.isDarwin then agent else agentLink;
    in
    {
      # Fixed paths on both OSes, so ssh, git and SSH_AUTH_SOCK do not branch.
      home.file = {
        ".ssh/1password-agent.sock".source = config.lib.file.mkOutOfStoreSymlink (
          if pkgs.stdenv.isDarwin then
            "${home}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          else
            "${home}/.1password/agent.sock"
        );
        ".ssh/1password-ssh-sign".source =
          if pkgs.stdenv.isDarwin then
            "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          else
            "${pkgs._1password-gui}/bin/op-ssh-sign";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        # On each SSH login, the new connection's forwarded agent becomes active.
        # sshd runs this with /bin/sh. It disables sshd's own xauth handling,
        # which X11Forwarding (off) would need.
        ".ssh/rc".text = ''
          if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
            ${pkgs.coreutils}/bin/ln -sfn "$SSH_AUTH_SOCK" "${agentLink}.tmp.$$" &&
              ${pkgs.coreutils}/bin/mv -T "${agentLink}.tmp.$$" "${agentLink}"
          fi
        '';
      };

      # .zshenv runs for every zsh, also inside tmux, where an inherited
      # SSH_AUTH_SOCK would otherwise win.
      programs.zsh.envExtra = lib.optionalString pkgs.stdenv.isLinux ''
        if [ -n "$SSH_CONNECTION" ] && [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "${agentLink}" ]; then
          export SSH_AUTH_SOCK_FORWARDED="$SSH_AUTH_SOCK"
        fi
      '' + ''
        export SSH_AUTH_SOCK="${sock}"
      '';

      # The default update-environment without SSH_AUTH_SOCK: attaching a client
      # must not replace the fixed socket.
      programs.tmux.extraConfig = ''
        set -g update-environment "DISPLAY KRB5CCNAME MSYSTEM SSH_ASKPASS SSH_AGENT_PID SSH_CONNECTION WAYLAND_DISPLAY WINDOWID XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE"
        set-environment -g SSH_AUTH_SOCK "${sock}"
      '' + lib.optionalString pkgs.stdenv.isLinux ''
        set-hook -g client-attached 'run-shell -b "${agentRelink}/bin/agent-relink #{client_pid}"'
        set-hook -g client-focus-in 'run-shell -b "${agentRelink}/bin/agent-relink #{client_pid}"'
        set-hook -g client-detached 'run-shell -b "${agentRelink}/bin/agent-relink"'
      '';

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
