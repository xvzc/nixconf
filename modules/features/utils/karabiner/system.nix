{
  pkgs,
  ...
}:
{
  homebrew = {
    enable = true;

    casks = [
      "karabiner-elements"
    ];
  };
}
