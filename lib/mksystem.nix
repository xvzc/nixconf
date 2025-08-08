{
  nixpkgs,
  inputs,
  outputs,
}:
{
  profile,
  system,
  user,
  host,
  ...
}@args:
let
  inherit (nixpkgs) lib;
  inherit (lib) nixosSystem;
  inherit (inputs.nix-darwin.lib) darwinSystem;

  ctx = rec {
    inherit (args) system user host;
    isDarwin = builtins.elem args.system lib.platforms.darwin;
    isLinux = builtins.elem args.system lib.platforms.linux;
    os = if isDarwin then "darwin" else "nixos";
  };

  builder = if ctx.isDarwin then darwinSystem else nixosSystem;
in
builder {
  inherit system;

  specialArgs = { inherit ctx inputs outputs; };
  modules = lib.lists.flatten [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;
    }
    { nixpkgs.config.allowUnfree = true; }
    (lib.optionalAttrs ctx.isDarwin inputs.nix-homebrew.darwinModules.nix-homebrew)
    (lib.optionalAttrs ctx.isDarwin inputs.home-manager.darwinModules.home-manager)
    (lib.optionalAttrs ctx.isLinux inputs.home-manager.nixosModules.home-manager)
    ../overlays.nix
    ../profiles/${profile}/overlays.nix
    ../profiles/${profile}/system
    ../hosts/${host}.nix
    {
      home-manager.extraSpecialArgs = { inherit ctx inputs outputs; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = lib.mkMerge [
        ../profiles/${profile}/user
        ../users/${user}.nix
      ];
    }
  ];
}
