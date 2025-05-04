{
  lib,
  pkgs,
  inputs,
  ...
}:
let
in
{
  nixpkgs.overlays = import ./overlays.nix { inherit inputs; };

  time.timeZone = "Asia/Seoul";
  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    btop
    coreutils
    curl
    docker_28
    docker-compose
    htop
    neovim
    openssh
    vim
    wget
  ];
}
