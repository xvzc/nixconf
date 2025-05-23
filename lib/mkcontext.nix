lib:
{ ... }@args:
rec {
  inherit (args) system;

  isDarwin = builtins.elem args.system lib.platforms.darwin;
  isLinux = builtins.elem args.system lib.platforms.linux;
  os = if isDarwin then "darwin" else "nixos";
}
