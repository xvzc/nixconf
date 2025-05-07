{
  inputs,
  ...
}:
{
  imports = [
    ./shared/profiles/mac.nix
  ];

  mac.wallpaper.source = "${inputs.assets}/wallpapers/anime-cat-clouds.jpg";
}
