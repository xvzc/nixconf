local augend = require("dial.augend")
local map = require("dial.map")

local common = {
  augend.integer.alias.decimal,
  augend.integer.alias.hex,
  augend.integer.alias.binary,
  augend.integer.alias.octal,
  augend.semver.alias.semver,
  augend.hexcolor.new({ case = "prefer_lower" }),
  augend.date.new({ pattern = "%Y/%m/%d", default_kind = "day" }),
  augend.date.new({ pattern = "%Y-%m-%d", default_kind = "day" }),
  augend.date.new({ pattern = "%m/%d", default_kind = "day", only_valid = true }),
  augend.date.new({ pattern = "%H:%M:%S", default_kind = "sec", only_valid = true }),
  augend.date.new({ pattern = "%H:%M", default_kind = "min", only_valid = true }),
  augend.constant.alias.en_weekday,
}

-- A filetype group replaces the default group, so it repeats the common list.
local function with_common(extra)
  local list = vim.list_extend({}, common)
  return vim.list_extend(list, extra)
end

require("dial.config").augends:register_group({ default = common })
require("dial.config").augends:on_filetype({
  markdown = with_common({ augend.misc.alias.markdown_header }),
})

local function dial(direction, mode)
  return function()
    map.manipulate(direction, mode)
  end
end

-- C-u counts up and C-d counts down (C-a is the tmux prefix)
vim.keymap.set("n", "<C-u>", dial("increment", "normal"))
vim.keymap.set("n", "<C-d>", dial("decrement", "normal"))
vim.keymap.set("n", "g<C-u>", dial("increment", "gnormal"))
vim.keymap.set("n", "g<C-d>", dial("decrement", "gnormal"))
vim.keymap.set("x", "<C-u>", dial("increment", "visual"))
vim.keymap.set("x", "<C-d>", dial("decrement", "visual"))
vim.keymap.set("x", "g<C-u>", dial("increment", "gvisual"))
vim.keymap.set("x", "g<C-d>", dial("decrement", "gvisual"))
