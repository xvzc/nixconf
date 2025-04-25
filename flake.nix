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
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      machines = {
        "desktop-personal-phys-01" = {
          system = "x86_64-linux";
          profile = "dev";
          username = "pablo";
          hostname = "nixos-desktop";
        };

        "desktop-work-phys-01" = {
          system = "x86_64-linux";
          profile = "dev";
          username = "pablo";
          hostname = "nixos-desktop";
        };

        "k8s-master-vm-01" = {
          system = "x86_64-linux";
          profile = "server";
          username = "k8s-master1";
          hostname = "nixos-desktop";
        };

        "macair-personal-phys-01" = {
          system = "aarch64-darwin";
          profile = "dev";
          username = "mario";
          hostname = "macbook-air-m2";
        };
      };

      lib = nixpkgs.lib;
      mkSystem = import ./lib/mksystem.nix { inherit inputs nixpkgs; };
    in
    {
      # darwinConfigurations = builtins.mapAttrs (k: v: mkSystem (v // { machine = k; })) (
      #   lib.filterAttrs (_: v: builtins.elem v.system lib.platforms.darwin) machines
      # );

      darwinConfigurations."macair-personal-phys-01" = mkSystem {
        system = "aarch64-darwin";
        profile = "dev";
        username = "mario";
        hostname = "macbook-air-m2";
        machine = "macair-personal-phys-01";
      };

      nixosConfigurations = builtins.mapAttrs (k: v: mkSystem (v // { machine = k; })) (
        lib.filterAttrs (_: v: builtins.elem v.system lib.platforms.linux) machines
      );
    };
}
