# SSH agent inside tmux (Linux). A tmux session outlives the connection that
# started it, so its panes would keep a stale SSH_AUTH_SOCK. Inside tmux,
# SSH_AUTH_SOCK is fixed instead to a link that follows the focused tmux
# client: its forwarded agent over SSH, otherwise no link (no agent). Shells
# outside tmux keep their own SSH_AUTH_SOCK.
#
# SSH_AUTH_SOCK is thus only ever a forwarded agent. When it is not a live
# socket, ssh and commit signing use the local agent (see the 1Password
# module), and sudo asks for the password.
{ ... }:
{
  hm.users.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      agentLink = "${config.home.homeDirectory}/.ssh/active-agent.sock";
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

          target=""
          if [ -n "$pid" ] && [ -r "/proc/$pid/environ" ]; then
            env=$(tr '\0' '\n' <"/proc/$pid/environ")
            if grep -q '^SSH_CONNECTION=' <<<"$env"; then
              sock=$(sed -n 's/^SSH_AUTH_SOCK=//p' <<<"$env")
              if [ -n "$sock" ] && [ "$sock" != "$link" ] && alive "$sock"; then
                target="$sock"
              fi
            fi
          fi

          # A local client, or no forwarded agent: no agent.
          if [ -z "$target" ]; then
            rm -f "$link"
            exit 0
          fi

          [ "$(readlink "$link" 2>/dev/null)" = "$target" ] && exit 0
          ln -sfn "$target" "$link.tmp.$$"
          mv -T "$link.tmp.$$" "$link"
        '';
      };
    in
    lib.mkIf pkgs.stdenv.isLinux {
      # The default update-environment without SSH_AUTH_SOCK: attaching a
      # client must not replace the fixed socket.
      programs.tmux.extraConfig = ''
        set -g update-environment "DISPLAY KRB5CCNAME MSYSTEM SSH_ASKPASS SSH_AGENT_PID SSH_CONNECTION WAYLAND_DISPLAY WINDOWID XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE"
        set-environment -g SSH_AUTH_SOCK "${agentLink}"
        set-hook -g client-attached 'run-shell -b "${agentRelink}/bin/agent-relink #{client_pid}"'
        set-hook -g client-session-changed 'run-shell -b "${agentRelink}/bin/agent-relink #{client_pid}"'
        set-hook -g client-focus-in 'run-shell -b "${agentRelink}/bin/agent-relink #{client_pid}"'
        set-hook -g client-detached 'run-shell -b "${agentRelink}/bin/agent-relink"'
      '';
    };
}
