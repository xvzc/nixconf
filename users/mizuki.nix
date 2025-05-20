{
  inputs,
  ctx,
  ...
}:
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/mountain-abstract.jpg";
}
