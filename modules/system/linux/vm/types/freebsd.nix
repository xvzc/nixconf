{ version, arch }:
let
  releases = {
    "15.0" = {
      "x86_64" = {
        baseUrl = "https://download.freebsd.org/releases/ISO-IMAGES/15.0/";
        isoFile = "FreeBSD-15.0-RELEASE-amd64-disc1.iso";
        sha256 = "sha256-zHOhTUsc+tqIC3jesLlK4PQ5FnQYwypnCPaPeVY8tQw=";
      };
    };
  };
  curRelease = releases."${version}"."${arch}";
in
{
  url = "${curRelease.baseUrl}/${curRelease.isoFile}";
  sha256 = curRelease.sha256;
}
