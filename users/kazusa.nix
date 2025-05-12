{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../modules/user/macos-general.nix
  ];

  user.macos-general = {
    wallpaper.source = "${inputs.assets}/wallpapers/anya-forger-spy-x.jpg";
  };
}
