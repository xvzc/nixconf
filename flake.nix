{
  description = "NixOS configurations";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # to use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      overlays = [
        (final: prev: {
          neovim = inputs.neovim-nightly.packages.${prev.system}.default;
        })
        (final: prev: {
          # gh CLI on stable has bugs.
          gh = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.gh;
        })
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit overlays nixpkgs inputs;
      };
    in
    {
      nixosConfigurations.desktop-home-01 = mkSystem "desktop-home-01" {
        system = "x86_64-linux";
        user = "jerry";
        isDarwin = false;
      };

      darwinConfigurations.macbook-air-m2 = mkSystem "macbook-air-m2" {
        system = "aarch64-darwin";
        user = "jerry";
        isDarwin = true;
      };
    };
}
