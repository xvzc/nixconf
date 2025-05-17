{
  inputs,
  ...
}:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [
        "${inputs.assets}/wallpapers/anime-girl-nun.jpg"
        "${inputs.assets}/wallpapers/anime-cat-clouds.jpg"
      ];

      wallpaper = [
        ", ${inputs.assets}/wallpapers/anime-girl-nun.jpg"
      ];
    };
  };
}
