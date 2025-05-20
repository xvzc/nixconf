# Original src: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{ inputs, ... }:
{
  additions = final: prev: {
    neovim-nightly = inputs.neovim-nightly.packages.${prev.system}.default;

    nanum-square-neo = final.callPackage ../pkgs/nanum-square-neo.nix { };
    im-select = final.callPackage ../pkgs/im-select.nix { };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
  };

  nixpkgs-unstable =
    final: prev:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = final.system;
        config.allowUnfree = true;
      };
    in
    {
      inherit unstable;

      _1password-gui = unstable._1password-gui;
      _1password-cli = unstable._1password-cli;

      skhd = unstable.skhd;
      yabai = unstable.yabai;

      wezterm = unstable.wezterm;
      bash-language-server = unstable.bash-language-server;
      tmuxPlugins.catppuccin = unstable.tmuxPlugins.catppuccin;
      gh = unstable.gh;
      slack = unstable.slack;
      kdePackages = unstable.kdePackages;
      wine = unstable.wine;
      rofi = unstable.rofi;

      # pipewire = unstable.pipewire;

      waybar = unstable.waybar;
      hyprland = unstable.hyprland;
      discord = unstable.discord;
    };

  wayland = {
  };
}
