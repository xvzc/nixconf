{
  pkgs,
  inputs,
  ...
}:
let
in
{
  imports = [
    ../../modules/base/dev.nix

    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/networking.nix
    ../../modules/darwin/system.nix
    ../../modules/darwin/users.nix
    ../../modules/darwin/yabai.nix
  ];

  darwin.yabai.enable = true;
  darwin.system = {
    dock.apps = [
      "${pkgs.wezterm}/Applications/WezTerm.app"
      "${pkgs.google-chrome}/Applications/Google Chrome.app"
      "${pkgs.spotify}/Applications/Spotify.app"
    ];
  };
}
