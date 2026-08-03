{
  pkgs,
  lib,
  ...
}:
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
    shellInit =
      # sh
      ''
        function nfu() {
          ${pkgs.nix}/bin/nix flake update nvim-xvzc assets --flake $NIXOS_CONFIG
        }

        function nic() {
          ${pkgs.nix}/bin/nix flake check
        }

        ${lib.optionalString pkgs.stdenv.isDarwin # sh
          ''
            function nis() {
              ${pkgs.nix}/bin/nix build \
                "$NIXOS_CONFIG#darwinConfigurations.$HOST.system" \
                -o $NIXOS_CONFIG/result \
                && sudo "$NIXOS_CONFIG/result/sw/bin/darwin-rebuild" switch \
                  --flake "$NIXOS_CONFIG#$HOST"
            }
          ''
        }

        ${lib.optionalString pkgs.stdenv.isLinux # sh
          ''
            function nis() {
              sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 \
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch \
                --flake "$NIXOS_CONFIG#$HOST"
            }
          ''
        }

        function nid() {
          nix develop $NIXOS_CONFIG#$1
        }
      '';
  };
}
