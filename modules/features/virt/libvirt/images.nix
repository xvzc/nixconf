# Official VM images, by OS, version and arch. The checksum is the one
# published next to the image (CHECKSUM.SHA256), for the compressed file.
{
  freebsd."15.1".x86_64 = {
    url = "https://download.freebsd.org/releases/VM-IMAGES/15.1-RELEASE/amd64/Latest/FreeBSD-15.1-RELEASE-amd64-BASIC-CLOUDINIT-ufs.qcow2.xz";
    sha256 = "e4ca4db889f8559c9b9dfcacc70405c038476f4b6d41649b152d3809a2ed9e1f";
  };
}
