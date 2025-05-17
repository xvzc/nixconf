{
  nixpkgs,
  inputs,
  outputs,
}:
{
  ...
}@args:
let
  ctx = import ./mkcontext.nix nixpkgs.lib args;
  homeDirectory = if ctx.isDarwin then "/Users/${ctx.user}" else "/home/${ctx.user}";
in
inputs.home-manager.lib.homeManagerConfiguration {
  # System is very important!
  pkgs = import nixpkgs {
    inherit (ctx) system;

    config.allowUnfree = true;
    overlays = [
      outputs.overlays.additions
      outputs.overlays.nixpkgs-unstable
    ];
  };

  extraSpecialArgs = { inherit ctx inputs outputs; };
  modules = [
    {
      home.username = ctx.user;
      home.homeDirectory = homeDirectory;
    }
    ../users/${ctx.user}.nix
  ];
}
