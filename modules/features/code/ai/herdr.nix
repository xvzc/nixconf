{ ctx, ... }:
{
  home-manager.users.${ctx.user} =
    {
      pkgs,
      lib,
      inputs,
      config,
      ...
    }:
    let
      jq = lib.getExe pkgs.jq;
      fzf = lib.getExe pkgs.fzf;
      curl = lib.getExe pkgs.curl;

      # One tab-separated line per agent pane: pane_id, display text. Workspaces
      # are ordered by number, panes by `pane list` order. The display text is
      # "<marker> <label padded> #<n> · <agent>(<status>)", where n counts agent
      # panes within the workspace and the marker is "•" on the active pane. The
      # active pane is $HERDR_ACTIVE_PANE_ID (set for popup commands), falling
      # back to the focused pane.
      agentList = pkgs.writeShellScript "herdr-agent-list" ''
        herdr="''${HERDR_BIN_PATH:-herdr}"
        workspaces=$("$herdr" workspace list)
        "$herdr" pane list | ${jq} -r --argjson ws "$workspaces" \
          --arg active "''${HERDR_ACTIVE_PANE_ID:-}" '
          [.result.panes[] | select((.agent // "") != "")] as $panes
          | [ ($ws.result.workspaces | sort_by(.number))[] as $x
              | {x: $x, p: [$panes[] | select(.workspace_id == $x.workspace_id)]}
              | select(.p | length > 0) ] as $g
          | ($g | map(.x.label | length) | max // 0) as $width
          | $g[]
          | .x as $x
          | .p
          | to_entries[]
          | .key as $i
          | .value
          | (if $active != "" then .pane_id == $active else .focused end) as $on
          | [
              .pane_id,
              ((if $on then "• " else "  " end)
                + $x.label + ((" " * ($width - ($x.label | length))) // "")
                + " #" + (($i + 1) | tostring) + " · "
                + .agent + "(" + .agent_status + ")")
            ]
          | @tsv'
      '';

      # Once per second the list is regenerated and pushed over fzf's --listen
      # socket with reload-sync, which keeps the old list on screen until the
      # new one is loaded.
      # --info-command replaces the info line, which drops the loading spinner.
      # An in-fzf `load:reload(sleep ...)` loop leaves input unresponsive
      # while --track and --id-nth are active.
      agentPicker = pkgs.writeShellScript "herdr-agent-picker" ''
        herdr="''${HERDR_BIN_PATH:-herdr}"
        dir=$(mktemp -d)
        trap 'kill "$refresher" 2>/dev/null; rm -rf "$dir"' EXIT
        sock="$dir/fzf.sock"
        (
          while sleep 1; do
            ${curl} -s --unix-socket "$sock" http://fzf -d "reload-sync(${agentList})" >/dev/null
          done
        ) &
        refresher=$!
        selected=$(${agentList} | ${fzf} --listen="$sock" \
          --delimiter '\t' --with-nth 2 \
          --track --id-nth 1 \
          --info-command='echo "$FZF_MATCH_COUNT/$FZF_TOTAL_COUNT"') || exit 0
        [ -n "$selected" ] || exit 0
        "$herdr" agent focus "$(printf '%s' "$selected" | cut -f1)"
      '';
    in
    {
      # ┏━━━━━━━━┓
      # ┃ HERDR  ┃
      # ┗━━━━━━━━┛
      imports = [
        "${inputs.home-manager-master}/modules/programs/herdr.nix"
      ];

      programs.herdr = {
        enable = true;
        package = pkgs.mv.tip.herdr;
        settings = {
          onboarding = false;
          session.resume_agents_on_restore = true;
          keys = {
            prefix = "ctrl+a";

            new_tab = "prefix+c";
            next_tab = "prefix+ctrl+n";
            previous_tab = "prefix+ctrl+p";

            split_horizontal = "prefix+minus";
            split_vertical = "prefix+_";

            zoom = "prefix+f";
            goto = "prefix+g";

            focus_pane_left = "ctrl+h";
            focus_pane_down = "ctrl+j";
            focus_pane_up = "ctrl+k";
            focus_pane_right = "ctrl+l";

            navigate_workspace_up = [ "up" "ctrl+p" ];
            navigate_workspace_down = [ "down" "ctrl+n" ];

            command = [
              {
                key = "ctrl+s";
                type = "popup";
                command = "${agentPicker}";
                description = "go to agent";
                width = "80%";
                height = "80%";
              }
            ];
          };
        };
      };

      home.file.".claude/hooks/herdr-agent-state.sh" = {
        source = "${pkgs.mv.tip.herdr.src}/src/integration/assets/claude/herdr-agent-state.sh";
        executable = true;
      };

      programs.claude-code.settings.hooks.SessionStart = [
        {
          matcher = "^(startup|resume|clear|compact|fork)$";
          hooks = [
            {
              type = "command";
              command = "bash '${config.home.homeDirectory}/.claude/hooks/herdr-agent-state.sh' session";
              timeout = 10;
            }
          ];
        }
      ];
    };
}
