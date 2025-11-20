{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:

buildGoModule rec {
  pname = "SpoofDPI";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "xvzc";
    repo = "SpoofDPI";
    rev = "v${version}";
    hash = "sha256-0vcDTxLY4NiAXmF8tOYwTcLihBTO6uZE5DQinPxfEiw=";
  };

  buildInputs = with pkgs; [
    libpcap
  ];

  vendorHash = "sha256-Blgl5EmbAa2UYqjc+BNZ/kF1YU6oXQYSOJ9e8UM9W68=";

  meta = {
    homepage = "https://github.com/xvzc/SpoofDPI";
    description = "Simple and fast anti-censorship tool written in Go";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ s0me1newithhand7s ];
  };
}
