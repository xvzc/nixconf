{
  ctx,
  lib,
  config,
  pub,
  ...
}:
with lib;
let
  cfg = config.features.essentials.ssh;

  # ssh settings for this machine from hosts.nix: drops its own entry and those
  # excluded on it, and a proxyJump through itself.
  toClientSettings =
    hosts:
    concatMapAttrs (
      name: entry:
      optionalAttrs (name != ctx.host && !(elem ctx.host (entry.excludeOn or [ ]))) {
        "Host ${name}" = removeAttrs entry (
          [ "excludeOn" ] ++ optional ((entry.proxyJump or null) == ctx.host) "proxyJump"
        );
      }
    ) hosts;
in
{
  options.features.essentials.ssh.server = {
    enable = mkEnableOption "the OpenSSH server";
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Public keys that may log in as the host's user (ctx.user).";
    };
    forwardSudoAuth = mkOption {
      type = types.bool;
      default = false;
      description = "Authenticate sudo over ssh with the forwarded agent (SSH_AUTH_SOCK). Local sudo keeps the password.";
    };
  };

  config = mkMerge (
    [
      {
        assertions = [
          {
            assertion = !cfg.server.enable || ctx.isLinux;
            message = "features.essentials.ssh.server is only supported on NixOS.";
          }
          {
            assertion = cfg.server.authorizedKeys == [ ] || cfg.server.enable;
            message = "features.essentials.ssh.server.authorizedKeys requires features.essentials.ssh.server.enable.";
          }
          {
            assertion = !cfg.server.forwardSudoAuth || cfg.server.enable;
            message = "features.essentials.ssh.server.forwardSudoAuth requires features.essentials.ssh.server.enable.";
          }
        ];

        hm.users.default = {
          # `ssh` attaches to tmux on hosts tagged "tmux"; see the script.
          programs.zsh.initContent =
            lib.mkOrder 1000 # sh
              ''
                ssh() { ~/.config/ssh/scripts/ssh-tmux "$@"; }
              '';

          xdg.configFile."ssh/scripts/ssh-tmux".source = ./dotfiles/scripts/ssh-tmux;

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;
            includes = [ "~/.ssh/config.d/*" ];

            settings = toClientSettings (import ./hosts.nix { inherit pub; });
          };

          # Every public key in pub.nix, for identityFile (the private keys
          # are in the agent).
          home.file = mapAttrs' (_: k: nameValuePair k.path { text = k.key; }) (pub.git // pub.host);
        };
      }
    ]
    # ┌───────┐
    # │ LINUX │
    # └───────┘
    # nix-darwin lacks some of these options, so they are not defined there at all.
    ++ optionals ctx.isLinux [
      (mkIf cfg.server.enable {
        services.openssh = {
          enable = true;
          ports = mkDefault [ 22 ];
          settings = {
            PermitRootLogin = mkDefault "no";
            PasswordAuthentication = mkDefault false;
            # Otherwise PAM still prompts for the password.
            KbdInteractiveAuthentication = mkDefault false;
          };
        };

        users.users.${ctx.user}.openssh.authorizedKeys.keys = cfg.server.authorizedKeys;
      })

      (mkIf cfg.server.forwardSudoAuth {
        security.pam.sshAgentAuth.enable = true;
        security.pam.services.sudo.sshAgentAuth = true;
      })
    ]
  );
}
