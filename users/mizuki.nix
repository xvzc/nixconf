{
  inputs,
  ctx,
  ...
}:
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/lofi-girl-listening-5120x2880-14887.jpg";
}
