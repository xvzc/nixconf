# Original src: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{
  inputs,
  pkgs,
  lib,
  ctx,
  ...
}:
let
  mkCacheSettings =
    keys:
    let
      toUrl = key: "https://${builtins.elemAt (builtins.match "^(.*)-[0-9]+:.*$" key) 0}";
      urls = map toUrl keys;
    in
    {
      substituters = urls;
      trusted-substituters = urls;
      trusted-public-keys = keys;
    };
in
{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    dates = "16:30";
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    interval = {
      Weekday = 1;
      Hour = 16;
      Minute = 30;
    };
  };

  nix.optimise.automatic = true;
  nix.settings = {
    experimental-features = "nix-command flakes fetch-closure";
    trusted-users = [
      "root"
      ctx.user
    ];
  }
  // mkCacheSettings [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];

  # ┌─────────────────┐
  # │ GLOBAL OVERLAYS │
  # └─────────────────┘
  nixpkgs.overlays = [
    # inputs.neovim-nightly-overlay.overlays.default
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };

      master = import inputs.nixpkgs-master {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };

      nanum-square-neo = final.callPackage ./pkgs/nanum-square-neo.nix { };
      spoofdpi = final.callPackage ./pkgs/spoofdpi.nix { };
    })
  ];
}
