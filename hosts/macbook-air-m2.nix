{
  lib,
  pkgs,
  ctx,
  pub,
  ...
}:
{
  imports = [
    ../modules/system/darwin/preferences.nix
    ../modules/features/wm/yabai
    ../modules/features/wm/aerospace
    ../modules/features/wm/omniwm
    ../modules/features/wm/amethyst
  ];

  config = lib.mkMerge [
    {
      features.wm.yabai.enable = false;
      # features.wm.aerospace.enable = false;
      # features.wm.omniwm.enable = false;
      # features.wm.amethyst.enable = true;

      # The user should already exist, but we need to set
      # this up so Nix knows what our home directory is.
      # https://github.com/LnL7/nix-darwin/issues/423
      users = {
        knownUsers = [ ctx.user ];
        users.${ctx.user} = {
          uid = 501; # This is the default uid for darwin system
          home = "/Users/${ctx.user}";
          shell = pkgs.zsh;
        };
      };

      networking = {
        hostName = ctx.host;
        computerName = ctx.host;
        localHostName = ctx.host;
        domain = ctx.host;
      };

      system.defaults.dock = {
        persistent-others = lib.mkForce [ ];
        persistent-apps = [
          "/Applications/Firefox.app" # LEAVE THIS AS IT IS!!
          "${pkgs.spotify}/Applications/Spotify.app"
          "${pkgs.wezterm}/Applications/WezTerm.app"
        ];
      };

    }
    # SSH hosts, reached over Tailscale MagicDNS.
    {
      hm.users.default = {
        programs.ssh.settings = {
          "Host nixos-desktop-01" = {
            hostname = "nixos-desktop-01.tailb7f463.ts.net";
            user = "mizuki";
            HostKeyAlias = "nixos-desktop-01";
            forwardAgent = true;
            identitiesOnly = true;
            StrictHostKeyChecking = "no";
            identityFile = "~/${pub.desktop.path}";
          };

          # Windows on the same machine (dual boot), so the same LAN address as
          # NixOS: HostKeyAlias keeps its host key apart in known_hosts.
          "Host windows-desktop" = {
            hostname = "172.20.0.100";
            user = "anonymous";
            HostKeyAlias = "windows-desktop";
          };

          "Host ${pub.router.name}" = {
            hostname = "router.tailb7f463.ts.net";
            user = "root";
            forwardAgent = true;
            identitiesOnly = true;
            StrictHostKeyChecking = "no";
            identityFile = "~/${pub.router.path}";
          };
        };

        home.file = {
          "${pub.desktop.path}".text = pub.desktop.key;
          "${pub.router.path}".text = pub.router.key;
        };
      };
    }
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    { system.stateVersion = 6; }
  ];
}
