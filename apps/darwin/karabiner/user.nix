{ ... }:
{
  xdg.configFile."karabiner/karabiner.json" = {
    text = # json
      ''
        {
          "global": { "show_in_menu_bar": false },
          "profiles": [
            {
              "complex_modifications": {
                "rules": [
                  {
                    "description": "Esc to ABC",
                    "manipulators": [
                      {
                        "from": {
                            "key_code": "escape",
                            "modifiers": { "optional": ["any"] }
                        },
                        "to": [
                            { "select_input_source": { "language": "en" } },
                            { "key_code": "escape" }
                        ],
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
