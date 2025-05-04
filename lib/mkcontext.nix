{ lib, args }:
let
in
{
  os = (lib.systems.elaborate args.system).parsed.kernel.name;
  isDarwin = builtins.elem args.system lib.platforms.darwin;
  isLinux = builtins.elem args.system lib.platforms.linux;
  inherit (args)
    user
    host
    system
    profile
    ;
}
