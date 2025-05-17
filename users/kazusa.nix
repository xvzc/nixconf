{
  inputs,
  ...
}:
{
  imports = [
    ./_profiles/dev
  ];

  wallpaper.source = "${inputs.assets}/wallpapers/anya-forger-spy-x.jpg";
}
