{ pkgs, lib, ... }:
{
  # ┌──────────────────┐ 
  # │ DARWIN_FUNCTIONS │ 
  # └──────────────────┘ 
  programs.zsh = lib.mkIf pkgs.stdenv.isDarwin {
    profileExtra = # sh
      ''
        function nfu() {
          nix flake update nvim-xvzc assets --flake $NIXCONF_DIR
        }

        function sfs() {
          nix build "$NIXCONF_DIR#darwinConfigurations.$HOST.system" \
            && sudo "$NIXCONF_DIR/result/sw/bin/darwin-rebuild" switch \
            --flake "$NIXCONF_DIR#$HOST";
        }

        function sft() {
          nix build "$NIXCONF_DIR#darwinConfigurations.$HOST.system";
        }

        function hfs() {
          home-manager switch --flake $NIXCONF_DIR;
        }

        function hft() {
          home-manager build --flake $NIXCONF_DIR;
        }
      '';
  };
}
