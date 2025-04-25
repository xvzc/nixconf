# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ inputs, nixpkgs }:
{ ... }@args:
# ┌──────────┐
# │ mkSystem │
# └──────────┘
let
  lib = nixpkgs.lib;
  mutliPlatformProfiles = [
    "dev"
    "server"
  ];
  ctx = args // rec {
    isDarwin = builtins.elem args.system nixpkgs.lib.platforms.darwin;
    isLinux = builtins.elem args.system nixpkgs.lib.platforms.linux;
    platform = if isDarwin then "darwin" else "linux";
  };
  bootstrap = if ctx.isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
in
bootstrap {
  system = ctx.system;
  modules = lib.lists.flatten [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;

      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;
      nixpkgs.overlays = import ../overlays.nix { inherit ctx inputs lib; };
    }
    (lib.optionals ctx.isDarwin [
      inputs.nix-homebrew.darwinModules.nix-homebrew
      inputs.home-manager.darwinModules.home-manager
    ])
    (lib.optionals ctx.isLinux [
      inputs.home-manager.nixosModules.home-manager
    ])
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${ctx.username} = ../profiles/${ctx.profile}/user;
      home-manager.extraSpecialArgs = { inherit ctx; };
    }
    ../profiles/${ctx.profile}/system
    ../machines/${ctx.machine}
  ];

  specialArgs = {
    inherit ctx inputs;
  };
}
