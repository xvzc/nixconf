{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nvim-xvzc = {
      url = "github:xvzc/nvim";
      flake = false;
    };

    assets = {
      url = "github:xvzc/assets";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
      ];
      allSystems = linuxSystems ++ darwinSystems;
      forSystems = systems: f: nixpkgs.lib.genAttrs systems f;

      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs outputs; };
    in
    {
      darwinConfigurations.macbook-air-m2 = mkSystem "macbook-air-m2" {
        platform = "darwin";
        profile = "dev";
        system = "aarch64-darwin";
        user = "kazusa";
        wm = "yabai";
      };

      nixosConfigurations.nixos-desktop-01 = mkSystem "nixos-desktop-01" {
        platform = "linux";
        profile = "dev";
        system = "x86_64-linux";
        user = "mizuki";
        wm = "hyprland";
      };
    };
}
