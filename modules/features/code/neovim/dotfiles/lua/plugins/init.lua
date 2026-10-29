-- Load order matters: list entries from top to bottom.
-- Entry: { name, event = "InsertEnter", opts = {}, config = function(opts) end,
--          after = function() end }
-- event, opts, config and after are optional. after runs once setup is done.
-- config: true (default) = auto setup, false = skip setup (no lua module),
--         function = custom setup.
local specs = {
  { "catppuccin", config = function() vim.cmd.colorscheme("catppuccin") end },
  { "notify", opts = {} }, -- external module: require("notify").setup(opts)
  { "plugins.noice" },
  { "plugins.bufferline" },
  { "plugins.lualine" },
  {
    "lastplace",
    config = false, -- vimscript plugin, no lua module to set up
    after = function()
      vim.g.lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
      vim.g.lastplace_ignore_buftype = "quickfix,nofile,help"
      vim.g.lastplace_open_folds = 0
    end,
  },
  { "plugins.treesitter" },
  { "plugins.lspconfig", event = "BufReadPre" },
  {
    "gitsigns",
    event = "BufReadPre",
    opts = {
      current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        virt_text_priority = 10000,
        delay = 500,
        ignore_whitespace = true,
      },
    },
  },
  { "plugins.conform", event = "BufReadPost" },
  { "plugins.indent-blankline", event = "BufReadPost" },
  {
    "nvim-surround",
    event = "BufReadPost",
    after = function()
      vim.keymap.set("n", "s", "ysiw", { silent = true, remap = true })
      vim.keymap.set("v", "s", "S", { silent = true, remap = true })
    end,
  },
  { "plugins.tmux", event = "VimEnter" },
  { "plugins.nvim-tree", event = "VimEnter" },
  { "plugins.oil", event = "VimEnter" },
  {
    "outline",
    event = "VimEnter",
    after = function()
      vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle outline" })
    end,
  },
  {
    "cbox",
    event = "VimEnter",
    after = function()
      vim.keymap.set({ "n", "x" }, "gb", function()
        require("cbox").toggle({ theme = "thin", visual_line = { style = "line" } })
      end, { silent = true })

      vim.keymap.set({ "n", "x" }, "gB", function()
        require("cbox").toggle({ theme = "bold", visual_line = { style = "line" } })
      end, { silent = true })
    end,
  },
  {
    "snacks",
    event = "VimEnter",
    opts = { picker = { enabled = true } },
  },
  { "plugins.blink-cmp", event = "InsertEnter" },
  { "plugins.blink-pairs", event = "InsertEnter" },
}

-- With spec.config, call spec.config(opts).
-- Otherwise "plugins.<name>" requires lua/plugins/<name>.lua as is, and any
-- other name is an external module: require(name).setup(opts).
local function load(spec)
  local name = spec[1]
  local ok, err = pcall(function()
    local config = spec.config
    if config == nil then
      config = true
    end

    if config == false then
      -- skip setup
    elseif type(config) == "function" then
      config(spec.opts or {})
    elseif name:find("^plugins%.") then
      require(name)
    else
      require(name).setup(spec.opts or {})
    end
    if spec.after then
      spec.after()
    end
  end)
  if not ok then
    vim.notify(("%s: %s"):format(name, err), vim.log.levels.ERROR)
  end
end

for _, spec in ipairs(specs) do
  if spec.event then
    vim.api.nvim_create_autocmd(spec.event, {
      group = vim.api.nvim_create_augroup("plugins-lazy-" .. spec[1], { clear = true }),
      once = true,
      callback = function()
        load(spec)
      end,
    })
  else
    load(spec)
  end
end
