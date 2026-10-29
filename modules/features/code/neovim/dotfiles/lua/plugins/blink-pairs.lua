require("blink.pairs").setup({
  mappings = {
    enabled = true,
    -- Only pair in insert mode, as nvim-autopairs did.
    cmdline = false,
    disabled_filetypes = { "snacks_picker_input" },
    wrap = {
      ["<C-b>"] = false,
      ["<C-S-b>"] = false,
    },
  },

  -- The highlight registration is what attaches buffers to the pair parser
  -- used by the mappings, so it stays enabled. An empty group list and a
  -- disabled matchparen keep it visually inert.
  highlights = {
    enabled = true,
    cmdline = false,
    groups = {},
    matchparen = { enabled = false },
  },
})
