{
  ctx,
  ...
}:
{
  imports = [
    ../hosts/shared/features/firefox.nix
  ];

  # ┌──────────────┐ 
  # │ HOME_MANAGER │ 
  # └──────────────┘ 
  home-manager.users.${ctx.user} =
    { inputs, ... }:
    {
      imports = [
        ./profiles/dev

        ../modules/user/wallpaper.nix
      ];

      wallpaper.source = "${inputs.assets}/wallpapers/shinra-kusakabe.jpg";
    };
}
