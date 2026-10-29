-- Skip completion inside comments (treesitter capture or syntax group).
local function in_comment()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  if vim.api.nvim_get_mode().mode == "i" then
    col = math.max(col - 1, 0)
  end

  local ok, captures =
    pcall(vim.treesitter.get_captures_at_pos, 0, row, col)
  if ok then
    for _, c in ipairs(captures) do
      if c.capture == "comment" then
        return true
      end
    end
  end

  for _, id in ipairs(vim.fn.synstack(row + 1, col + 1)) do
    if vim.fn.synIDattr(vim.fn.synIDtrans(id), "name") == "Comment" then
      return true
    end
  end

  return false
end

require("blink.cmp").setup({
  enabled = function()
    return not in_comment()
  end,

  keymap = {
    preset = "none",
    ["<C-Space>"] = { "show", "fallback" },
    ["<C-e>"] = {
      function(cmp)
        return cmp.scroll_documentation_up(2)
      end,
      "fallback",
    },
    ["<C-y>"] = {
      function(cmp)
        return cmp.scroll_documentation_down(2)
      end,
      "fallback",
    },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
    ["<C-d>"] = { "cancel", "fallback" },
  },

  snippets = { preset = "default" },

  completion = {
    list = {
      selection = { preselect = false, auto_insert = true },
    },
    menu = {
      border = "none",
      max_height = vim.o.pumheight,
      winblend = vim.o.pumblend,
      draw = {
        columns = { { "label" }, { "kind_icon" } },
        components = {
          label = {
            width = { max = 30 },
            text = function(ctx)
              return ctx.label
            end,
          },
        },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 0,
      window = { border = "none" },
    },
    ghost_text = { enabled = false },
  },

  sources = {
    default = { "lsp", "snippets", "buffer", "path" },
    per_filetype = {
      gitcommit = { "buffer" },
    },
    providers = {
      snippets = { score_offset = 100 },
      lsp = {
        transform_items = function(_, items)
          local kinds = vim.lsp.protocol.CompletionItemKind
          return vim.tbl_filter(function(item)
            return item.kind ~= kinds.Text and item.kind ~= kinds.Snippet
          end, items)
        end,
      },
    },
  },

  cmdline = {
    keymap = {
      preset = "none",
      ["<Tab>"] = { "select_and_accept" },
      ["<C-n>"] = {
        function(cmp)
          if not cmp.is_menu_visible() then
            return true
          end
          if #cmp.get_items() == 1 then
            return cmp.select_and_accept()
          end
          return cmp.select_next()
        end,
      },
      ["<C-p>"] = {
        function(cmp)
          if not cmp.is_menu_visible() then
            return true
          end
          if #cmp.get_items() == 1 then
            return cmp.select_and_accept()
          end
          return cmp.select_prev()
        end,
      },
      ["<C-j>"] = {
        function()
          local key = vim.api.nvim_replace_termcodes("<Down>", true, false, true)
          vim.api.nvim_feedkeys(key, "n", false)
          return true
        end,
      },
      ["<C-k>"] = {
        function()
          local key = vim.api.nvim_replace_termcodes("<Up>", true, false, true)
          vim.api.nvim_feedkeys(key, "n", false)
          return true
        end,
      },
    },
    sources = function()
      local type = vim.fn.getcmdtype()
      if type == "/" or type == "?" then
        return { "buffer" }
      end
      if type == ":" or type == "@" then
        return { "cmdline" }
      end
      return {}
    end,
    completion = {
      list = {
        selection = { preselect = false, auto_insert = true },
      },
      menu = { auto_show = true },
      ghost_text = { enabled = false },
    },
  },

  appearance = {
    kind_icons = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "󰙎",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "󰰤",
    },
  },
})

-- gray
vim.api.nvim_set_hl(
  0,
  "BlinkCmpLabelDeprecated",
  { bg = "NONE", strikethrough = true, fg = "#808080" }
)
-- blue
vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { bg = "NONE", fg = "#569CD6" })
-- light blue
vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { bg = "NONE", fg = "#9CDCFE" })
vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { link = "BlinkCmpKindVariable" })
vim.api.nvim_set_hl(0, "BlinkCmpKindText", { link = "BlinkCmpKindVariable" })
-- pink
vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { bg = "NONE", fg = "#C586C0" })
vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { link = "BlinkCmpKindFunction" })
-- front
vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
vim.api.nvim_set_hl(0, "BlinkCmpKindProperty", { link = "BlinkCmpKindKeyword" })
vim.api.nvim_set_hl(0, "BlinkCmpKindUnit", { link = "BlinkCmpKindKeyword" })
