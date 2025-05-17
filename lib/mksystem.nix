{
  nixpkgs,
  inputs,
  outputs,
}:
{
  ...
}@args:
let
  inherit (nixpkgs) lib;
  inherit (lib) nixosSystem;
  inherit (inputs.nix-darwin.lib) darwinSystem;

  ctx = import ./mkcontext.nix lib args;
  builder = if ctx.isDarwin then darwinSystem else nixosSystem;
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
    (lib.optionalAttrs ctx.isDarwin inputs.nix-homebrew.darwinModules.nix-homebrew)
    ../hosts/${ctx.host}
  ];
}
