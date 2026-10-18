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
          ${pkgs.nix}/bin/nix flake update \
            --flake "$NIXOS_CONFIG" \
            --reference-lock-file "$NIXOS_CONFIG/flake.$HOST.lock" \
            --output-lock-file "$NIXOS_CONFIG/flake.$HOST.lock" \
            "$@"
        }

        function nic() {
          ${pkgs.nix}/bin/nix flake check
        }

        ${lib.optionalString pkgs.stdenv.isDarwin # sh
          ''
            function nbs() {
              local lock="$NIXOS_CONFIG/flake.$HOST.lock"
              if [ ! -f "$lock" ]; then
                echo "nbs: missing host lock '$lock'" >&2
                return 1
              fi
              local system
              system=$(
                ${pkgs.nix}/bin/nix build \
                  "$NIXOS_CONFIG#darwinConfigurations.$HOST.system" \
                  -o "$NIXOS_CONFIG/result" \
                  --print-out-paths \
                  --reference-lock-file "$lock"
              ) \
                && sudo ${pkgs.nix}/bin/nix-env \
                  -p /nix/var/nix/profiles/system \
                  --set "$system" \
                && sudo "$system/sw/bin/darwin-rebuild" activate
            }
          ''
        }

        ${lib.optionalString pkgs.stdenv.isLinux # sh
          ''
            function nbs() {
              local lock="$NIXOS_CONFIG/flake.$HOST.lock"
              if [ ! -f "$lock" ]; then
                echo "nbs: missing host lock '$lock'" >&2
                return 1
              fi
              local system
              system=$(
                NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 ${pkgs.nix}/bin/nix build \
                  "$NIXOS_CONFIG#nixosConfigurations.$HOST.config.system.build.toplevel" \
                  --no-link \
                  --print-out-paths \
                  --reference-lock-file "$lock"
              ) \
                && sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild \
                  switch --store-path "$system" --no-reexec
            }
          ''
        }

        function nid() {
          nix develop $NIXOS_CONFIG#$1
        }
      '';
  };
}
