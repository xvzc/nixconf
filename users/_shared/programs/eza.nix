{
  lib,
  ...
}:
{
  enable = true;
  enableZshIntegration = true;
  extraOptions = [
    "--group-directories-first"
    "-g"
  ];
}
