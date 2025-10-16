{
  config,
  pkgs,
  ctx,
  ...
}:
{
  home.packages = [
    pkgs.discord
  ];

  home.activation.addDiscordSettings =
    let
      home = config.home.homeDirectory;
      configDir = {
        darwin = "${home}/Library/Application Support/discord";
        linux = "${home}/.config/discord";
      };
    in
    # sh
    ''
      TARGET_DIR="${configDir.${ctx.os}}";
      SETTINGS_FILE="$TARGET_DIR/settings.json"

      run mkdir -p "$TARGET_DIR"

      if [ ! -f "$SETTINGS_FILE" ]; then
        echo "{}" > "$SETTINGS_FILE"
      fi

      # jq로 SKIP_HOST_UPDATE 키 추가 또는 갱신
      tmp_file=$(run mktemp)
      run ${pkgs.jq}/bin/jq '.SKIP_HOST_UPDATE = true' \
        "$SETTINGS_FILE" > "$tmp_file" \
        && run mv "$tmp_file" "$SETTINGS_FILE"
    '';
}
