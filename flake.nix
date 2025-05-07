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
    flake-utils.url = "github:numtide/flake-utils";

    nvim = {
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
      nix-darwin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      mkDarwin = import ./lib/mksystem.nix {
        inherit lib inputs outputs;
        builder = nix-darwin.lib.darwinSystem;
        extraModules = [
          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.home-manager.darwinModules.home-manager
        ];
      };

      mkNixos = import ./lib/mksystem.nix {
        inherit lib inputs outputs;
        builder = nixpkgs.lib.nixosSystem;
        extraModules = [
          inputs.home-manager.nixosModules.home-manager
        ];
      };

      configurations = [
        {
          system = "aarch64-darwin";
          user = "kazusa";
          host = "macbook-air-m2";
        }
        {
          system = "x86_64-linux";
          user = "mizuki";
          host = "nixos-desktop-01";
        }
        {
          system = "x86_64-linux";
          user = "nezuko";
          host = "nixos-desktop-02";
        }
        # {
        #   system = "x86_64-linux";
        #   user = "nezuko";
        #   host = "kube-master-01";
        # }
        # {
        #   system = "x86_64-linux";
        #   user = "nezuko";
        #   host = "kube-worker-01";
        # }
        # {
        #   system = "x86_64-linux";
        #   user = "nezuko";
        #   host = "kube-worker-02";
        # }
      ];
    in
    {
      overlays = import ./overlays { inherit inputs; };
      darwinConfigurations = lib.listToAttrs (
        lib.map (c: {
          name = c.host;
          value = mkDarwin c;
        }) (lib.filter (x: builtins.elem x.system lib.platforms.darwin) configurations)
      );

      nixosConfigurations = lib.listToAttrs (
        lib.map (c: {
          name = c.host;
          value = mkNixos c;
        }) (lib.filter (x: builtins.elem x.system lib.platforms.linux) configurations)
      );
    };
}
