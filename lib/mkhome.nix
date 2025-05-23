{
  nixpkgs,
  inputs,
  outputs,
}:
{
  user,
  host,
  ...
}@args:
let
  ctx = import ./mkcontext.nix nixpkgs.lib args;
  homeDirectory = if ctx.isDarwin then "/Users/${user}" else "/home/${user}";
in
inputs.home-manager.lib.homeManagerConfiguration {
  # System is very important!
  pkgs = import nixpkgs {
    inherit (ctx) system;
    config.allowUnfree = true;
  };

  extraSpecialArgs = { inherit ctx inputs outputs; };
  modules = [
    {
      home.username = ctx.user;
      home.homeDirectory = homeDirectory;
    }
    ../overlays.nix
    ../profiles/${ctx.profile}/overlays.nix
    ../profiles/${ctx.profile}/user
    ../users/${ctx.user}.nix
  ];
}
