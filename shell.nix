{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    commitlint
  ];

  shellHook = # sh
    ''
      export name="nix:config"
    '';
}
