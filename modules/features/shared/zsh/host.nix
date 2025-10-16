{ pkgs, ... }:
{
  environment.pathsToLink = [
    "/share/zsh"
  ];

  environment.shells = [
    pkgs.zsh
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      nic = "nix flake check";
    };
    shellInit = # sh
      ''
        function nis() {
          platform=$(uname)
          if [[ "$platform" == 'Darwin' ]]; then
            nix build \
              "$NIXCONF_DIR#darwinConfigurations.$HOST.system" \
              -o $NIXCONF_DIR/result &&
              sudo "$NIXCONF_DIR/result/sw/bin/darwin-rebuild" switch \
                --flake "$NIXCONF_DIR#$HOST"
          elif [[ "$platform" == 'Linux' ]]; then
            sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 \
              nixos-rebuild switch --flake "$NIXCONF_DIR#$HOST"
          fi
        }
      '';
  };
}
