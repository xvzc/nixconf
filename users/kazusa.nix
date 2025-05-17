{
  inputs,
  ...
}:
{
  imports = [
    ./_profiles/dev-user-darwin.nix

    ../modules/user/wallpaper.nix
  ];

  user.features = {
    wallpaper.source = "${inputs.assets}/wallpapers/anya-forger-spy-x.jpg";
  };
}
