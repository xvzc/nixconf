{
  ctx,
  lib,
  pkgs,
  ...
}@args:
let
in
{
  imports = [ ../${ctx.platform}.nix ];

  time.timeZone = "Asia/Seoul";
  environment.pathsToLink = [ "/share/zsh" ];

  # ┌─────────────────────┐
  # │ dev system_packages │
  # └─────────────────────┘
  environment.systemPackages =
    # ┌────────┐
    # │ common │
    # └────────┘
    with pkgs;
    [
      btop
      coreutils
      curl
      docker_28
      docker-compose
      gcc
      gnupg
      htop
      neovim
      openssh
      unzip
      vim
      wget
      zip
    ]
    # ┌────────┐
    # │ darwin │
    # └────────┘
    ++ lib.optionals ctx.isDarwin [
      pam-reattach
    ];

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    noto-fonts-emoji
    material-design-icons
    nanum-square-neo

    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "D2Coding"
      ];
    })
  ];

  services = {
    yabai = import ./services/yabai.nix args;
    skhd = import ./services/skhd.nix args;
  };

  # programs = {
  #   zsh = {
  #     enable = true;
  #     enableCompletion = true;
  #   };
  # };
}
