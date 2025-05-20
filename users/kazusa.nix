{
  inputs,
  ...
}:
{
  imports = [
    ../modules/user/wallpaper.nix
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/anya-forger-spy-x.jpg";
}
