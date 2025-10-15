{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    { ... }:
    {
      programs.zsh = {

        initContent = lib.mkMerge [
          (lib.mkOrder 1500 # sh
            ''
              function nfu() {
                nix flake update nvim-xvzc assets --flake $NIXCONF_DIR
              }
            ''
          )

          # ┌──────────────────┐
          # │ DARWIN_FUNCTIONS │
          # └──────────────────┘
          (lib.mkIf pkgs.stdenv.isDarwin (
            lib.mkOrder 1500 # sh
              ''
                function sfs() {
                  nix build \
                    "$NIXCONF_DIR#darwinConfigurations.$HOST.system" \
                    -o $NIXCONF_DIR/result \
                    && sudo "$NIXCONF_DIR/result/sw/bin/darwin-rebuild" switch \
                    --flake "$NIXCONF_DIR#$HOST";
                }

                function sft() {
                  nix build "$NIXCONF_DIR#darwinConfigurations.$HOST.system";
                }
              ''
          ))

          # ┌─────────────────┐
          # │ LINUX_FUNCTIONS │
          # └─────────────────┘
          (lib.mkIf pkgs.stdenv.isLinux (
            lib.mkOrder 1500 # sh
              ''
                function sfs() {
                	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 \
                    nixos-rebuild switch --flake "$NIXCONF_DIR#$HOST"
                }

                function sft() {
                	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 \
                    nixos-rebuild test --flake "$NIXCONF_DIR#$HOST"
                }
              ''
          ))
        ];
      };
    };
}
