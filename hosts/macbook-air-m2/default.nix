{
  pkgs,
  ...
}:
{
  imports = [
    ../_shared/profiles/workstation-macos.nix
  ];

  host.darwin.system = {
    dock.apps = [
      "${pkgs.wezterm}/Applications/WezTerm.app"
      "${pkgs.google-chrome}/Applications/Google Chrome.app"
      "${pkgs.spotify}/Applications/Spotify.app"
    ];
  };
}
