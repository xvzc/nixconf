# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  user,
  isDarwin ? false,
}:

let
  darwin = {
    systemFunc = inputs.darwin.lib.darwinSystem;
    home-manager = inputs.home-manager.darwinModules.home-manager;
  };

  nixos = {
    systemFunc = nixpkgs.lib.nixosSystem;
    home-manager = inputs.home-manager.nixosModules.home-manager;
  };

  systemFunc = if isDarwin then darwin.systemFunc else nixos.systemFunc;
  home-manager = if isDarwin then darwin.home-manager else nixos.home-manager;

  curEnv = {
    type = if isDarwin then "darwin" else "nixos";
    name = name;
    system = system;
    user = user;
  };

  hostConfig = ../hosts/${curEnv.name}.nix;
  moduleConfig = ../modules/${curEnv.type};

in
systemFunc {
  inherit system;

  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }

    # Allow unfree packages.
    { nixpkgs.config.allowUnfree = true; }

    (if isDarwin then inputs.nix-homebrew.darwinModules.nix-homebrew else { })
    home-manager
    hostConfig
    moduleConfig
  ];

  specialArgs = {
    inherit curEnv inputs;
  };
}
