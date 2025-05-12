{
  pkgs,
  ...
}:
let
in
{
  imports = [
    ../../modules/host/base/dev.nix

    ../../modules/host/darwin/homebrew.nix
    ../../modules/host/darwin/identity.nix
    ../../modules/host/darwin/system.nix
    ../../modules/host/darwin/yabai.nix
  ];

  host.darwin.yabai.enable = true;
  host.darwin.system = {
    dock.apps = [
      "${pkgs.wezterm}/Applications/WezTerm.app"
      "${pkgs.google-chrome}/Applications/Google Chrome.app"
      "${pkgs.spotify}/Applications/Spotify.app"
    ];
  };
}
