{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/host/macos-host-gui.nix
  ];

  host.darwin.system = {
    dock.apps = [
      "${pkgs.wezterm}/Applications/WezTerm.app"
      "${pkgs.google-chrome}/Applications/Google Chrome.app"
      "${pkgs.spotify}/Applications/Spotify.app"
    ];
  };
}
