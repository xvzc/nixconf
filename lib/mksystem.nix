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

    isDarwin = lib.elem system lib.platforms.darwin;
    isLinux = lib.elem system lib.platforms.linux;
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
        inputs.NixVirt.nixosModules.default
      ];
    };
  };

  auth = import ../auth.nix;
in
platforms.${platform}.builder {
  inherit system;

  modules = lib.lists.flatten [
    {
      nixpkgs.config.allowUnfree = true;
    }

    platforms.${platform}.modules

    ../global.nix
    ../profiles/${profile}
    ../hosts/${host}.nix
    (builtins.filter builtins.pathExists [
      ../hosts/hardware-configurations/${host}.nix
    ])

    {
      home-manager.extraSpecialArgs = {
        inherit (args) wallpaper;
        inherit
          ctx
          inputs
          outputs
          auth
          ;
      };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = lib.mkMerge [
        ../users/${user}.nix
        { home.enableNixpkgsReleaseCheck = false; }
      ];
    }
  ];

  specialArgs = {
    inherit (args) wallpaper;
    inherit
      ctx
      inputs
      outputs
      auth
      ;
  };
}
