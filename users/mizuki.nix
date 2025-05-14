{
  inputs,
  ...
}:
{
  imports = [
    ../modules/user/nixos-user-dev.nix
  ];

  user.features = {
    wallpaper.source = "${inputs.assets}/wallpapers/anime-girl-nun.jpg";
  };
}
