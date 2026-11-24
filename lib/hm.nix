# `hm.users.<name>` takes Home Manager modules for `home-manager.users.<name>`.
# `default` stands for the host's primary user (`ctx.user`, from flake.nix).
#
# Each definition is forwarded on its own and in order, so Home Manager sees
# the same module list as with `home-manager.users.<name>` written directly.
{
  lib,
  options,
  ctx,
  ...
}:
let
  userName = name: if name == "default" then ctx.user else name;

  # Split a definition of `hm.users` into plain attrsets of users, keeping any
  # `mkIf` or `mkMerge` around it on each user's module.
  split =
    value:
    if value._type or null == "merge" then
      lib.concatMap split value.contents
    else if value._type or null == "if" then
      map (lib.mapAttrs (_: lib.mkIf value.condition)) (split value.content)
    else
      [ value ];

  # Rename `default`, keeping the file each definition came from for messages.
  forward =
    def:
    map (
      users:
      lib.mkDefinition {
        inherit (def) file;
        value = lib.mapAttrs' (name: lib.nameValuePair (userName name)) users;
      }
    ) (split def.value);
in
{
  options.hm.users = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
    description = "Home Manager modules per user; `default` is the host's primary user.";
  };

  config.home-manager.users = lib.mkMerge (
    lib.concatMap forward options.hm.users.definitionsWithLocations
  );
}
