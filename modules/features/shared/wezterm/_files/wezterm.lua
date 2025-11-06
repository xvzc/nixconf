local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

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
-- window = wezterm.target_triple
-- window:toast_notification('wezterm', "hello", nil, 4000)

local ok, mutable = pcall(require, ".mutable")
if not ok or (mutable == nil) or (type(mutable) ~= "table") then
	mutable = {}
end

config.term = "wezterm"

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"

config.cursor_blink_ease_out = "Constant"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_rate = 0
config.default_cursor_style = "SteadyBlock"

config.audible_bell = "Disabled"

config.color_scheme_dirs = { "~/.config/wezterm/colors" }
config.color_scheme = "Miami"

config.font = wezterm.font_with_fallback({
	"JetBrainsMonoNL NF",
	"NanumSquare Neo",
	"D2Coding",
})

config.keys = {
	{ key = "-", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "=", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "-", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
	{ key = "=", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
	{
		key = "Tab",
		mods = "CTRL",
		action = wezterm.action.SendKey({ key = "Tab", mods = "CTRL" }),
	},
	{
		key = "Tab",
		mods = "SHIFT|CTRL",
		action = wezterm.action.SendKey({ key = "Tab", mods = "SHIFT|CTRL" }),
	},
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

if is_darwin then
	config.font_size = 12.5
	config.window_decorations = "RESIZE | MACOS_FORCE_SQUARE_CORNERS"
	-- config.window_decorations = "RESIZE"
	config.window_padding = {
		left = is_darwin and 6 or 0,
		right = 0,
		top = 0,
		bottom = 0,
	}

	table.insert(config.keys, {
		key = "-",
		mods = "CMD",
		action = wezterm.action.DisableDefaultAssignment,
	})

	table.insert(config.keys, {
		key = "=",
		mods = "CMD",
		action = wezterm.action.DisableDefaultAssignment,
	})
end

if is_linux then
	config.font_size = 12.2
	config.window_decorations = "NONE"
	config.enable_wayland = false
	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}
end

return recursive_merge(config, mutable)
