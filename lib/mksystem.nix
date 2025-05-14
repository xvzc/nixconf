{
  nixpkgs,
  inputs,
  outputs,
}:
{
  ...
}@ctx:
let
  inherit (inputs.nix-darwin.lib) darwinSystem;
  inherit (nixpkgs.lib) nixosSystem;

  lib = nixpkgs.lib;
  isDarwin = builtins.elem ctx.system nixpkgs.lib.platforms.darwin;
  builder = if isDarwin then darwinSystem else nixosSystem;
in
builder {
  inherit (ctx) system;

  specialArgs = { inherit ctx inputs outputs; };
  modules = lib.lists.flatten [
    {
      nix.settings.experimental-features = "nix-command flakes";
      nix.optimise.automatic = true;
    }
    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        outputs.overlays.additions
        outputs.overlays.nixpkgs-unstable
      ];
    }
    (lib.optionalAttrs isDarwin inputs.nix-homebrew.darwinModules.nix-homebrew)
    ../hosts/${ctx.host}
  ];
}
