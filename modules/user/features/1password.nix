{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    lib.optionals pkgs.stdenv.isLinux [
      # Since `_1password-gui` for Darwin is marked as broken,
      # we install it only on Linux. On macOS instead,
      # `1Password` will be installed via Homebrew. See also
      # https://github.com/NixOS/nixpkgs/issues/254944
      _1password-gui
    ]
    ++ [
      _1password-cli
    ];
  xdg.configFile."1Password/ssh/agent.toml".text = # toml
    ''
      [[ssh-keys]]
      vault = "Personal"

      [[ssh-keys]]
      vault = "Work"
    '';
}
