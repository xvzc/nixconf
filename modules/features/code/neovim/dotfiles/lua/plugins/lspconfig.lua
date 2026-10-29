-- ┌────────────────────────────────┐
-- │ Language Server Configurations │
-- └────────────────────────────────┘
vim.lsp.config("*", {
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = true,
      },
    },
  },
})

-- c / cpp
vim.lsp.enable("clangd")
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--header-insertion=never",
    "--header-insertion-decorators=false",
    -- "--query-driver=/run/current-system/sw/bin/g++,/run/current-system/sw/bin/gcc*",
  },
})

-- go
vim.lsp.enable("gopls")
vim.lsp.enable("golangci_lint_ls")

-- lua
vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false, -- removes asking for luassert
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- mdx
vim.lsp.enable("mdx_analyzer")

-- nix
vim.lsp.enable("nixd")

-- python
vim.lsp.enable("pylsp")
vim.lsp.config("pylsp", {
  settings = {
    pylsp = {
      plugins = {
        pyflakes = { enabled = false },
        pycodestyle = { enabled = false },
        flake8 = {
          ignore = { "E203" },
          enabled = true,
        },
      },
    },
  },
})

-- rust
vim.lsp.enable("rust_analyzer")
vim.lsp.config("rust_analyzer", {
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
  settings = {
    ["rust-analyzer"] = {
      enabled = true,
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
      cargo = {
        allFeatures = true,
      },
      completion = { autocomplete = true },
    },
  },
})

-- sh
vim.lsp.enable("bashls")

-- terraform
vim.lsp.enable("terraformls")
vim.lsp.enable("tflint")

-- typescript
vim.lsp.enable("ts_ls")

-- ┌──────────────┐
-- │ Integrations │
-- └──────────────┘
vim.lsp.handlers["client/registerCapability"] = (function(overridden)
  return function(err, res, ctx)
    local result = overridden(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
      return
    end
    for bufnr, _ in pairs(client.attached_buffers) do
      -- CUSTOM on_attach
      -- client.server_capabilities.semanticTokensProvider = nil
      if client.server_capabilities.document_highlight then
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
          buffer = 0,
        })
      end
    end
    return result
  end
end)(vim.lsp.handlers["client/registerCapability"])

local border = {
  { "┌", "FloatBorder" },
  { "─", "FloatBorder" },
  { "┐", "FloatBorder" },
  { "│", "FloatBorder" },
  { "┘", "FloatBorder" },
  { "─", "FloatBorder" },
  { "└", "FloatBorder" },
  { "│", "FloatBorder" },
}

local handlers = vim.lsp.handlers

handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = border,
})

handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = border,
  })

handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = false,
  })

vim.diagnostic.config({
  float = {
    focusable = false,
    source = true,
    border = "rounded",
    header = "",
    prefix = "",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  virtual_text = false,
  severity_sort = true,
  update_in_insert = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      callback = function()
        vim.lsp.buf.clear_references()
      end,
      buffer = 0,
    })

    vim.keymap.set("n", "gd", function()
      Snacks.picker.lsp_definitions()
    end, opts)
    vim.keymap.set("n", "gr", function()
      Snacks.picker.lsp_references()
    end, opts)
    vim.keymap.set("n", "gi", function()
      Snacks.picker.lsp_implementations()
    end, opts)

    vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>i", vim.diagnostic.open_float, opts)

    vim.keymap.set("n", "<leader>[", function()
      vim.diagnostic.jump({ count = -1 })
    end, opts)
    vim.keymap.set("n", "<leader>]", function()
      vim.diagnostic.jump({ count = 1 })
    end, opts)

    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set(
      "n",
      "<F1>",
      vim.lsp.buf.signature_help,
      { noremap = true, silent = true }
    )
  end,
})
