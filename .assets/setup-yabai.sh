YABAI_BIN="$(which yabai)"
YABAI_HASH="$(shasum -a 256 "$YABAI_BIN" | cut -d " " -f 1)"
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$YABAI_HASH $YABAI_BIN --load-sa" \
  | sudo tee /private/etc/sudoers.d/yabai

