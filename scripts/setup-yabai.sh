sudo nvram boot-args=-arm64e_preview_abi # Enable non-Apple signed binaries

YABAI=$(which yabai)
CHECKSUM=$(shasum -a 256 "$YABAI" | cut -d " " -f 1)
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$CHECKSUM $YABAI --load-sa" |
  sudo tee /private/etc/sudoers.d/yabai

# csrutil enable --without fs --without debug --without nvram

