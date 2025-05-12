function nfu() {
  nix flake update nvim-xvzc assets --flake $NIXCONF_DIR
}

function sfs() {
  nfu && nix build "$NIXCONF_DIR#darwinConfigurations.$NIX_HOST.system" \
    && "$NIXCONF_DIR/result/sw/bin/darwin-rebuild" switch \
    --flake "$NIXCONF_DIR#$NIX_HOST";
}

function sft() {
  nix build "$NIXCONF_DIR#darwinConfigurations.$NIX_HOST.system";
}

function hfs() {
  nfu && home-manager switch --flake $NIXCONF_DIR;
}

function hft() {
  home-manager build --flake $NIXCONF_DIR;
}
