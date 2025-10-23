{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];

  shellHook = # sh
    ''
      export name="nix:config"
    '';
}
