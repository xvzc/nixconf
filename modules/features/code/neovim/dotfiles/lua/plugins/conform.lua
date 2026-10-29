vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

require("conform").setup({
  formatters_by_ft = {
    -- Conform will run multiple formatters sequentially
    -- You can customize some of the format options for the filetype
    -- See :help conform.format
    -- Conform will run the first available formatter
    typst = { "typstyle", lsp_format = "fallback" },
    c = { "clang-format" },
    sh = { "shfmt" },
    go = { "golangci-lint" },
    cpp = { "clang-format" },
    nix = { "nixfmt", lsp_format = "fallback" },
    lua = { "stylua" },
    python = { "black", lsp_format = "fallback" },
    rust = { "rustfmt", lsp_format = "fallback" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    terraform = { "terraform_fmt", lsp_format = "fallback" },
    toml = { "tombi", lsp_format = "fallback" },
  },
})

require("conform").formatters.injected = {
  -- Set the options field
  options = {
    -- Set individual option values
    ignore_errors = true,
    lang_to_formatters = {
      lua = { "stylua" },
    },
  },
}

vim.keymap.set({ "n" }, "<C-g>", function()
  require("conform").format({ async = true })
end)
