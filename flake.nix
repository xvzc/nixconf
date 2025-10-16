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

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

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

      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs outputs; };

      configurations = [
        {
          profile = "dev";
          system = "aarch64-darwin";
          user = "kazusa";
          host = "macbook-air-m2";
          os = "darwin";
          wm = "yabai";
        }
        {
          profile = "dev";
          system = "x86_64-linux";
          user = "mizuki";
          host = "nixos-desktop-01";
          os = "linux";
          wm = "hyprland";
        }
        # {
        #   system = "x86_64-linux";
        #   user = "nezuko";
        #   host = "nixos-desktop-02";
        #   os = "nixos";
        # }
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
      # ┌─────────┐
      # │ OUTPUTS │
      # └─────────┘
      darwinConfigurations = lib.listToAttrs (
        lib.map (c: {
          name = c.host;
          value = mkSystem c;
        }) (lib.filter (x: builtins.elem x.system lib.platforms.darwin) configurations)
      );

      nixosConfigurations = lib.listToAttrs (
        lib.map (c: {
          name = c.host;
          value = mkSystem c;
        }) (lib.filter (x: builtins.elem x.system lib.platforms.linux) configurations)
      );
    };
}
