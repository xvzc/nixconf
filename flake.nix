{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # url = "github:nix-community/home-manager?rev=64020f453bdf3634bf88a6bbce7f3e56183c8b2b";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    zjstatus.url = "github:dj95/zjstatus";

    nvim-xvzc = {
      url = "github:xvzc/nvim";
      flake = false;
    };

    assets = {
      url = "github:xvzc/assets";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [
        "aarch64-darwin"
      ];
      allSystems = linuxSystems ++ darwinSystems;
      forSystems = systems: f: nixpkgs.lib.genAttrs systems f;

      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs outputs; };
    in
    {
      darwinConfigurations.macbook-air-m2 = mkSystem "macbook-air-m2" {
        platform = "darwin";
        profile = "dev";
        system = "aarch64-darwin";
        user = "kazusa";
      };

      nixosConfigurations.nixos-desktop-01 = mkSystem "nixos-desktop-01" {
        platform = "linux";
        profile = "dev";
        system = "x86_64-linux";
        user = "mizuki";
      };

      devShells.aarch64-darwin.neovim-developer =
        let
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        in
        pkgs.mkShell {
          inputsFrom = [
            inputs.neovim-nightly-overlay.devShells.aarch64-darwin.default
          ];

          buildInputs = with pkgs; [
            python313Packages.pynvim
            lua-language-server
          ];

          shellHook = # sh
            ''
              url="$(git config --get remote.origin.url 2>/dev/null || true)"
              if ! printf '%s' "$url" | grep -Eq "github.com/.*/neovim.git"; then
                [[ $(basename $(pwd)) != 'neovim' ]] && rm -rf runtime
                echo "Not a neovim repository" >&2 
                exit 1
              fi

              export name="nix:neovim-developer"
              exec zsh
            '';
        };

    };
}
