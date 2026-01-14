{
  lib,
  fetchzip,
  buildGoModule,
  pkgs,
}:
buildGoModule rec {
  pname = "SpoofDPI";
  version = "1.2.0";
  repo = "https://github.com/xvzc/SpoofDPI";

  src = fetchzip {
    url = "${repo}/releases/download/v${version}/spoofdpi-${version}.tar.gz";
    hash = "sha256-yxrDmY/U0fMOCMN0nrkssi6tqMXoSQOiZEpMMqQoydY=";
  };

  # Include libpcap only on non-Linux systems (e.g., macOS)
  buildInputs = lib.optionals (!pkgs.stdenv.isLinux) [
    pkgs.libpcap
  ];

  vendorHash = "sha256-WqIAE5j3pqyGg5fdA75h9r40QB/lLQO7lgJyI3P7Jgk=";

  env = {
    CGO_ENABLED = if (!pkgs.stdenv.isLinux) then 1 else 0;
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.build=nixos"
  ];

  # Inject the commit hash from the COMMIT file in the artifact
  preBuild = ''
    ldflags+=" -X main.commit=$(cat COMMIT)"
  '';

  meta = {
    homepage = "https://github.com/xvzc/SpoofDPI";
    description = "Simple and fast anti-censorship tool written in Go";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      s0me1newithhand7s
      xvzc
    ];
  };
}
