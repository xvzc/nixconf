# Original Source: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{ inputs, ... }:
{
  additions = final: prev: {
    nanum-square-neo = final.callPackage ../pkgs/nanum-square-neo.nix { };
  };

  overrides = final: prev: {
    neovim = inputs.neovim-nightly.packages.${prev.system}.default;

    gh = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.gh;
    wezterm = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.wezterm;
    kitty = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.kitty;
    alacritty = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.alacritty;
    yabai = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.yabai;
    skhd = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.skhd;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  nixpkgs-unstable = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
