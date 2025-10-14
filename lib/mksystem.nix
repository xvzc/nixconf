{
  nixpkgs,
  inputs,
  outputs,
}:
{
  system,
  user,
  host,
  os,
  ...
}@args:
let
  inherit (nixpkgs) lib;
  ctx = { inherit (args) user host os; };

  platforms = {
    darwin = {
      builder = inputs.nix-darwin.lib.darwinSystem;
      modules = [
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.home-manager.darwinModules.home-manager
      ];
    };

    nixos = {
      builder = nixpkgs.lib.nixosSystem;
      modules = [
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
in
platforms.${os}.builder {
  inherit system;

  modules = lib.lists.flatten [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.allow-unsafe-native-code-during-evaluation = true;
      nix.optimise.automatic = true;
      nixpkgs.config.allowUnfree = true;
    }
    platforms.${os}.modules
    ../overlays.nix
    ../hosts/${host}.nix
    {
      home-manager.extraSpecialArgs = {
        inherit ctx inputs outputs;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      # home-manager.users.${user} = lib.mkMerge [
      # ];
    }
    ../users/${user}.nix
  ];

  specialArgs = {
    inherit ctx inputs outputs;
  };
}
