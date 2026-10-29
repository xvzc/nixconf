vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

vim.cmd("filetype plugin indent on")

vim.loader.enable()

vim.deprecate = function() end

require("preferences")
require("autocmds")

require("plugins")

require("clipboard")
require("keymaps")
require("styles")
