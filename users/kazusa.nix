{
  inputs,
  ...
}:
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/shinra-kusakabe.jpg";
}
