{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
      mkHome = import ./lib/mkhome.nix { inherit nixpkgs inputs outputs; };

      configurations = [
        {
          system = "aarch64-darwin";
          profile = "workstation";
          user = "kazusa";
          host = "macbook-air-m2";
        }
        {
          system = "x86_64-linux";
          profile = "workstation";
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
      # ┌─────────┐
      # │ OUTPUTS │
      # └─────────┘
      overlays = import ./overlays { inherit inputs; };

      pubkeys = {
        home = {
          name = "home.pub";
          text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIOn17UKMSvSOCQ6/XH+sqBjbpSbu+r0ECJEnVZ7niy";
        };

        pers = {
          name = "pers.pub";
          text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZZ3IHZk+M07W5NhhKWLq0wmoFQ+xi4Mk8isnJcjVe5";
        };

        work = {
          name = "work.pub";
          text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtHXAUu74FYAyhBgsPTzvofhr0YDQ1SDWczpupcUjdc";
        };
      };

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

      homeConfigurations = lib.listToAttrs (
        lib.map (c: {
          name = "${c.user}@${c.host}";
          value = mkHome c;
        }) configurations
      );
      # - OUTPUTS - 8< -----
    };
}
