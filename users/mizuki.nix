{
  inputs,
  ctx,
  ...
}:
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/duckgirl-darkmode.jpg";
}
