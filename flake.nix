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
  };

  outputs =
    { nixpkgs, nix-darwin, ... }@inputs:
    let
      lib = nixpkgs.lib;
      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs; };
      mkHome = import ./lib/mkhome.nix { inherit nixpkgs inputs; };
      configurations = [
        {
          system = "aarch64-darwin";
          profile = "dev";
          user = "mario";
          host = "macair-personal-phys-01";
        }
        {
          system = "x86_64-linux";
          profile = "dev";
          user = "pablo";
          host = "desktop-personal-phys-01";
        }
        # {
        #   system = "x86_64-linux";
        #   profile = "linux-dev";
        #   user = "mario";
        #   host = "desktop-work-phys-01";
        # }
        # {
        #   system = "x86_64-linux";
        #   profile = "linux-server";
        #   user = "master1";
        #   host = "kube-master-vm-01";
        # }
      ];
    in
    {

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
    };
}
