{ pkgs, lib, ... }:
{
  # ┌──────────────────┐
  # │ DARWIN_FUNCTIONS │
  # └──────────────────┘
  programs.zsh = {

    initContent = lib.mkMerge [
      (lib.mkOrder 1500 # sh
        ''
          function nfu() {
            nix flake update nvim-xvzc assets --flake $NIXCONF_DIR
          }
        ''
      )

      (lib.mkIf pkgs.stdenv.isDarwin (
        lib.mkOrder 1500 # sh
          ''
            function sfs() {
              nix build "$NIXCONF_DIR#darwinConfigurations.$HOST.system" \
                && sudo "$NIXCONF_DIR/result/sw/bin/darwin-rebuild" switch \
                --flake "$NIXCONF_DIR#$HOST";
            }

            function sft() {
              nix build "$NIXCONF_DIR#darwinConfigurations.$HOST.system";
            }
          ''
      ))

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
}
