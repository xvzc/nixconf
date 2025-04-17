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

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-config = {
      url = "github:xvzc/nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    overlays = [
      (final: prev: {
        gh = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.gh;
        neovim = inputs.neovim-nightly.packages.${prev.system}.default;
      })
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit
        self
        overlays
        nixpkgs
        inputs
        ;
    };
  in {
    lib = nixpkgs.lib // (import ./lib/utils.nix);
    nixosConfigurations.pablo = mkSystem {
      os = "nixos";
      user = "pablo";
      host = "nixos-desktop";
      system = "x86_64-linux";
      setupFunc = nixpkgs.lib.nixosSystem;
      sysModules = [
        inputs.home-manager.nixosModules.home-manager
      ];
    };

    darwinConfigurations.mario = mkSystem {
      os = "darwin";
      user = "mario";
      host = "macbook-air-m2";
      system = "aarch64-darwin";
      setupFunc = inputs.nix-darwin.lib.darwinSystem;
      sysModules = [
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  };
}
