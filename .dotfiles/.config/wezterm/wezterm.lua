-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.term = "wezterm"

config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = "NeverPrompt"

config.cursor_blink_ease_out = "Constant"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_rate = 0
config.default_cursor_style = "SteadyBlock"

config.audible_bell = "Disabled"

-- config.colors = require("themes/miami")
config.font_size = 12.0
config.color_scheme_dirs = { "/Users/mario/.config/wezterm/colors" }
config.color_scheme = "Miami"

local padding = 6
config.window_padding = {
	left =0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- wezterm.on("window-resized", function(window, pane)
-- 	local dimensions = window:get_dimensions()
-- 	local overrides = window:get_config_overrides() or {}
-- 	local value = dimensions.is_full_screen and 0 or 6
--
-- 	overrides.window_padding = {
-- 		left = value,
-- 		right = 0,
-- 		top = 0,
-- 		bottom = 0,
-- 	}
--
-- 	window:set_config_overrides(overrides)
-- end)

config.font = wezterm.font_with_fallback({
	"JetBrainsMonoNL Nerd Font",
	"NanumSquare Neo",
	"D2Coding",
})

config.keys = {
	{ key = "-", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "=", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "-", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
	{ key = "=", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
}

local function recursive_merge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (t1[k] ~= nil and type(t1[k]) == "table") then
			recursive_merge(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

local ok, mutable = pcall(require, ".mutable")
if not ok or (mutable == nil) or (type(mutable) ~= "table") then
	return config
end

return recursive_merge(config, mutable)
