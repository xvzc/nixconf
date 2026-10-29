if vim.env.TMUX == nil or vim.env.TMUX == "" then
  return
end

require("tmux").setup({
  copy_sync = {
    enable = false,
  },
  resize = {
    enable_default_keybindings = false,
  },
  swap = {
    enable_default_keybindings = false,
  },
  navigation = {
    -- cycles to opposite pane while navigating into the border
    cycle_navigation = false,
    -- enables default keybindings (C-hjkl) for normal mode
    enable_default_keybindings = false,
    persist_zoom = false,
    -- synchronizes registers when pressing p and P.
    sync_registers_keymap_put = false,

    -- synchronizes registers when pressing (C-r) and ".
    sync_registers_keymap_reg = false,
  },
})

vim.keymap.set({ "n", "i" }, "<C-h>", function()
  require("tmux").move_left()
end, { silent = true })
vim.keymap.set({ "n", "i" }, "<C-j>", function()
  require("tmux").move_bottom()
end, { silent = true })
vim.keymap.set({ "n", "i" }, "<C-k>", function()
  require("tmux").move_top()
end, { silent = true })
vim.keymap.set({ "n", "i" }, "<C-l>", function()
  require("tmux").move_right()
end, { silent = true })
