{ pkgs, lib, ... }:
{
  environment.pathsToLink = [
    "/share/zsh"
  ];

  environment.shells = [
    pkgs.zsh
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    promptInit = "";
    shellInit = # sh
      ''
        function nfu() {
          ${pkgs.nix}/bin/nix flake update nvim-xvzc assets --flake $NIXCONF_DIR
        }

        function nic() {
          ${pkgs.nix}/bin/nix flake check
        }

        ${lib.optionalString pkgs.stdenv.isDarwin # sh
          ''
            function nis() {
              ${pkgs.nix}/bin/nix build \
                "$NIXCONF_DIR#darwinConfigurations.$HOST.system" \
                -o $NIXCONF_DIR/result \
                && sudo "$NIXCONF_DIR/result/sw/bin/darwin-rebuild" switch \
                  --flake "$NIXCONF_DIR#$HOST"
            }
          ''
        }

        ${lib.optionalString pkgs.stdenv.isLinux # sh
          ''
            function nis() {
              sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 \
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "$NIXCONF_DIR#$HOST"
            }
          ''
        }
      '';
  };
}
