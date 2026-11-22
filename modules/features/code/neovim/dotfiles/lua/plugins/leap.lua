-- Ported from https://github.com/xvzc/nvim (lua/plugins/extras/editor/leap.lua),
-- keeping only the <leader>f mapping.
local leap = require("leap")

vim.keymap.set({ "n", "x", "o" }, "<leader>f", function()
  leap.leap({
    windows = { vim.api.nvim_get_current_win() },
    inclusive = true,
    inputlen = 2,
  })
end)

leap.opts.preview = false
leap.opts.safe_labels = ""
leap.opts.labels = "sfnjklhodweimbuyvrgtaqpcxz"
leap.opts.on_beacons = function(targets, _, _)
  for _, t in ipairs(targets) do
    -- Overwrite the `offset` value in all beacons.
    -- target.beacon looks like: { <offset>, <extmark_opts> }
    if t.label and t.beacon then
      t.beacon[1] = 0
    end
  end
  -- vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
  vim.api.nvim_set_hl(0, "LeapMatch", { link = "None" })
  vim.api.nvim_set_hl(0, "LeapLabel", { fg = "#1cff03", bg = "#000000" })
end

vim.api.nvim_set_hl(0, "LeapMatch", { link = "None" })
vim.api.nvim_set_hl(0, "LeapLabel", { fg = "#1cff03", bg = "#000000" })
