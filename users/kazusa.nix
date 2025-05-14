{
  inputs,
  ...
}:
{
  imports = [
    ../modules/user/macos-user-dev.nix
  ];

  user.features = {
    wallpaper.source = "${inputs.assets}/wallpapers/anya-forger-spy-x.jpg";
  };
}
