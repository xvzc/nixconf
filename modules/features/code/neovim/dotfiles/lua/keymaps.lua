local silent_noremap = { silent = true, noremap = true }
local silent_noremap_expr = { silent = true, noremap = true, expr = true }

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>-", ":sp<CR><C-w>j", silent_noremap)
vim.keymap.set("n", "<leader>_", ":vsp<CR><C-w>l", silent_noremap)

-- vim.keymap.set("n", "<leader>h", "<C-w>h", silent_noremap)
-- vim.keymap.set("n", "<leader>j", "<C-w>j", silent_noremap)
-- vim.keymap.set("n", "<leader>k", "<C-w>k", silent_noremap)
-- vim.keymap.set("n", "<leader>l", "<C-w>l", silent_noremap)

vim.keymap.set("n", "<leader>q", function()
  local config = vim.api.nvim_win_get_config(0)
  if config.relative ~= "" then
    vim.api.nvim_win_close(0, false)
  else
    vim.api.nvim_buf_delete(0, {})
  end
end)

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', silent_noremap)

vim.keymap.set({ "n", "v" }, "<leader>d", '"+d', silent_noremap)
vim.keymap.set("n", "<leader>D", '"+D', silent_noremap)

vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', silent_noremap)

vim.keymap.set("n", "<F5>", "<C-l>", silent_noremap)
vim.keymap.set("x", "A", "gg^oG$", silent_noremap)

-- diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true })

vim.keymap.set("n", "<C-a>", "<nop>")
