{
  inputs,
  ...
}:
{
  imports = [
    ./shared/profiles/mac.nix
  ];

  mac.wallpaper.source = "${inputs.wallpapers}/anime-cat-clouds.jpg";
}
