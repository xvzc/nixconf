{
  pkgs,
  ctx,
  ...
}:
let
in
{
  imports = [
    ../../modules/darwin/customizations.nix
  ];

  darwin.customizations = {
    user = ctx.user;
    host = ctx.host;
    ui = {
      wallpaper.source = ../../.assets/wallpaper.jpeg;
      yabai.enable = true;
      dock.apps = [
        "/Applications/WezTerm.app"
        "${pkgs.google-chrome}/Applications/Google Chrome.app"
        "${pkgs.spotify}/Applications/Spotify.app"
      ];
    };
  };
}
