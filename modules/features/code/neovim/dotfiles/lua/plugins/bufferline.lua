local point_color = "#fad9d9"

local function create_navigation_func(n)
  return function()
    require("bufferline").go_to(n, true)
  end
end

require("bufferline").setup({
  options = {
    modified_icon = "●",
    themable = true,
    show_close_icon = false,
    show_buffer_close_icons = false,
    left_trunc_marker = "",
    right_trunc_marker = "",
    -- numbers = function(opts)
    --   return string.format("%s", opts.ordinal)
    -- end,
    numbers = "ordinal",
    separator_style = { "", "" },
    -- "", ""
    tab_size = 15,
    -- diagnostics = "nvim_lsp", -- | "nvim_lsp" | "coc",
  },
  highlights = {
    indicator_selected = {
      fg = point_color,
    },
    buffer_selected = {
      fg = point_color,
      bold = true,
      italic = true,
    },
  },
})

vim.keymap.set({ "n" }, "<leader>1", create_navigation_func(1), { silent = true })
vim.keymap.set({ "n" }, "<leader>2", create_navigation_func(2), { silent = true })
vim.keymap.set({ "n" }, "<leader>3", create_navigation_func(3), { silent = true })
vim.keymap.set({ "n" }, "<leader>4", create_navigation_func(4), { silent = true })
vim.keymap.set({ "n" }, "<leader>5", create_navigation_func(5), { silent = true })
vim.keymap.set({ "n" }, "<leader>6", create_navigation_func(6), { silent = true })
vim.keymap.set({ "n" }, "<leader>7", create_navigation_func(7), { silent = true })
vim.keymap.set({ "n" }, "<leader>8", create_navigation_func(8), { silent = true })
vim.keymap.set({ "n" }, "<leader>9", create_navigation_func(9), { silent = true })
vim.keymap.set({ "n" }, "<leader>0", create_navigation_func(10), { silent = true })
vim.keymap.set({ "n" }, "<C-Tab>", "<cmd>BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set({ "n" }, "<C-S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { silent = true })
