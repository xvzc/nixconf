{
  nixpkgs,
  inputs,
  outputs,
}:
host:
{
  platform,
  profile,
  system,
  user,
  ...
}@args:
let
  inherit (nixpkgs) lib;
  ctx = {
    inherit host;
    inherit (args)
      user
      platform
      wm
      ;
  };

  platforms = {
    darwin = {
      builder = inputs.nix-darwin.lib.darwinSystem;
      modules = [
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.home-manager.darwinModules.home-manager
      ];
    };

    linux = {
      builder = nixpkgs.lib.nixosSystem;
      modules = [
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
in
platforms.${platform}.builder {
  inherit system;

  modules = lib.lists.flatten [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;
      nixpkgs.config.allowUnfree = true;
    }

    platforms.${platform}.modules

    ../overlays.nix
    ../profiles/${profile}
    ../hosts/${host}.nix
    (builtins.filter builtins.pathExists [
      ../hosts/hardware-configurations/${host}.nix
    ])

    {
      home-manager.extraSpecialArgs = {
        inherit ctx inputs outputs;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = ../users/${user}.nix;
    }
  ];

  specialArgs = {
    inherit ctx inputs outputs;
  };
}
