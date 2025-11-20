{ ... }:
{
  xdg.configFile."karabiner/karabiner.json" = {
    text = # json
      ''
        {
          "profiles": [
            {
              "complex_modifications": {
                "rules": [
                  {
                    "description": "Esc to ABC",
                    "manipulators": [
                      {
                        "from": { "key_code": "escape" },
                        "to_after_key_up": [
                          {
                            "select_input_source": {
                              "input_source_id": "com.apple.keylayout.ABC",
                              "language": "en"
                            }
                          }
                        ],
                        "to_if_alone": [{ "key_code": "escape" }],
                        "type": "basic"
                      }
                    ]
                  }
                ]
              },
              "name": "Default profile",
              "selected": true,
              "virtual_hid_keyboard": {
                  "indicate_sticky_modifier_keys_state": false,
                  "keyboard_type_v2": "ansi"
              }
            }
          ]
        }
      '';
  };
}
