# `vm-guest`: runs the guests, and (`vm-guest define`, from the service below)
# applies the definitions built by ./guests.nix.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.virt.libvirt;
  built = cfg.built;
  net = cfg.network.name;

  # name -> "field" as a bash associative array literal.
  table =
    field:
    lib.concatStrings (
      lib.mapAttrsToList (name: g: "[${name}]=${lib.escapeShellArg (toString g.${field})} ") built.guests
    );

  vmGuest = pkgs.writeShellApplication {
    name = "vm-guest";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.diffutils
      pkgs.gnugrep
      pkgs.libvirt
      pkgs.openssh
      pkgs.qemu-utils
      pkgs.xz
    ];
    text = ''
      usage() {
        cat <<'USAGE'
      Usage: vm-guest <command> [name]

        up       start (returns at once; ssh waits for the guest)
        down     shut down (forced after 60s)
        list     show the guests, their state and address
        ssh      start if needed, then ssh in (extra args go to ssh)
        reboot   reboot (asks the guest, like down)
        console  attach to the serial console (detach: Ctrl-])
        reinstall
                 erase the disk and reinstall from the image; the next boot
                 is a first boot again. Asks first.

      [name] may be omitted when there is one guest.
      USAGE
      }

      virsh() { command virsh -c qemu:///system "$@"; }

      guests=(${lib.concatStringsSep " " (lib.attrNames built.guests)})
      declare -A image=(${table "image"}) disk=(${table "disk"}) size=(${table "size"})
      declare -A ip=(${table "ip"}) domain=(${table "domain"})
      state_dir=${lib.escapeShellArg cfg.stateDir}

      # The guest's disk, from its image, if it has none.
      create_disk() {
        local name=$1
        [ -e "''${disk[$name]}" ] && return 0
        echo "vm-guest: creating the disk of $name" >&2
        local tmp="''${disk[$name]}.tmp.$$"
        # Not for other users: it holds the guest's keys and test data.
        umask 007
        xz -dc "''${image[$name]}" >"$tmp"
        qemu-img resize -q "$tmp" "''${size[$name]}G"
        mv "$tmp" "''${disk[$name]}"
      }

      is_running() { [ "$(virsh domstate "$1" 2>/dev/null)" = "running" ]; }

      wait_ssh() {
        local name=$1 i
        for i in $(seq 180); do
          if timeout 1 bash -c ">/dev/tcp/''${ip[$name]}/22" 2>/dev/null; then
            return 0
          fi
          [ "$i" = 1 ] && echo "vm-guest: waiting for ssh on $name (''${ip[$name]})" >&2
          sleep 1
        done
        echo "vm-guest: ssh on $name is not reachable" >&2
        return 1
      }

      # Run by the service, as root: the network, then each guest's disk and
      # definition. A running guest gets a changed definition at its next
      # start; a changed network is restarted, which cuts the guests off it.
      define() {
        local net_xml=${built.network} applied="$state_dir/${net}.xml"
        if ! cmp -s "$net_xml" "$applied"; then
          if virsh net-info ${net} >/dev/null 2>&1; then
            virsh net-destroy ${net} >/dev/null 2>&1 || true
          fi
          virsh net-define "$net_xml" >/dev/null
          cp "$net_xml" "$applied"
        fi
        virsh net-autostart ${net} >/dev/null
        if ! virsh net-info ${net} | grep -q '^Active: *yes'; then
          virsh net-start ${net} >/dev/null
        fi

        local name
        for name in "''${guests[@]}"; do
          create_disk "$name"
          virsh define "''${domain[$name]}" >/dev/null
          virsh autostart --disable "$name" >/dev/null
        done
      }

      cmd=''${1:-}
      [ $# -gt 0 ] && shift
      case $cmd in
        define) define; exit ;;
        list)
          for g in "''${guests[@]}"; do
            printf '%-20s %-12s %s\n' "$g" "$(virsh domstate "$g" 2>/dev/null || echo undefined)" "''${ip[$g]}"
          done
          exit
          ;;
        "" | -h | --help | help) usage; exit ;;
      esac

      # The guest name, which may be omitted when there is one.
      name=""
      if [ $# -gt 0 ] && [ -n "''${disk[$1]+x}" ]; then
        name=$1
        shift
      elif [ ''${#guests[@]} -eq 1 ]; then
        name=''${guests[0]}
      else
        echo "vm-guest: name a guest: ''${guests[*]}" >&2
        exit 2
      fi

      case $cmd in
        up)
          is_running "$name" || virsh start "$name" >/dev/null
          ;;
        down)
          is_running "$name" || exit 0
          virsh shutdown "$name" >/dev/null
          for _ in $(seq 60); do
            is_running "$name" || exit 0
            sleep 1
          done
          echo "vm-guest: $name did not shut down; forcing it off" >&2
          virsh destroy "$name" >/dev/null
          ;;
        ssh)
          is_running "$name" || virsh start "$name" >/dev/null
          wait_ssh "$name"
          exec ssh "$name" "$@"
          ;;
        console)
          exec virsh console "$name"
          ;;
        reboot)
          if ! is_running "$name"; then
            echo "vm-guest: $name is not running" >&2
            exit 1
          fi
          virsh reboot "$name" >/dev/null
          ;;
        reinstall)
          echo "vm-guest: everything on $name is erased, and it is reinstalled from the image." >&2
          echo "          Its next boot is a first boot again." >&2
          # No answer (no input) cancels.
          answer=""
          read -r -p "Reinstall $name? [y/N] " answer || true
          case $answer in
            [yY] | [yY][eE][sS]) ;;
            *) echo "vm-guest: cancelled" >&2; exit 1 ;;
          esac
          if is_running "$name"; then virsh destroy "$name" >/dev/null; fi
          rm -f "''${disk[$name]}"
          create_disk "$name"
          echo "vm-guest: $name is reinstalled; start it with vm-guest up" >&2
          ;;
        *)
          usage >&2
          exit 2
          ;;
      esac
    '';
  };

  # zsh completion: commands, then a guest name.
  completion =
    pkgs.writeTextDir "share/zsh/site-functions/_vm-guest"
      #sh
      ''
        #compdef vm-guest
        local -a commands guests
        commands=(
          'up:start a guest'
          'down:shut a guest down (forced after 60s)'
          'reboot:reboot a guest'
          'list:show the guests, their state and address'
          'ssh:start a guest if needed, then ssh in'
          'console:attach to the serial console'
          'reinstall:erase the disk and reinstall from the image'
        )
        guests=(${lib.escapeShellArgs (lib.attrNames built.guests)})

        if (( CURRENT == 2 )); then
          _describe -t commands 'vm-guest command' commands
          return
        fi
        case $words[2] in
          list|help) ;;
          *)
            (( CURRENT == 3 )) && _describe -t guests 'guest' guests
            ;;
        esac
      '';
in
lib.mkIf cfg.enable {
  environment.systemPackages = [
    vmGuest
    completion
  ];

  systemd.services.vm-define = {
    description = "Define the libvirt network and VM guests";
    after = [
      "libvirtd.service"
      "systemd-tmpfiles-setup.service"
    ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${vmGuest}/bin/vm-guest define";
    };
  };
}
