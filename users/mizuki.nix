{
  inputs,
  ...
}:
{
  imports = [
    ./_profiles/dev
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/mangekyo-sharingan-1.png";
}
