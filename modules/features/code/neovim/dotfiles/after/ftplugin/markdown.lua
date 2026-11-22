vim.bo.shiftwidth = 2
vim.bo.tabstop = 2

-- Toggles the task-list checkbox ("- [ ]" <-> "- [x]") of a line, wherever the
-- cursor is on it. Lines without a checkbox are left as they are.
local function toggle_checkbox(lnum)
  local line = vim.fn.getline(lnum)
  local prefix, mark = line:match("^(%s*[-*+] %[)([ xX])%]")
  if not prefix then
    prefix, mark = line:match("^(%s*%d+[.)] %[)([ xX])%]")
  end
  if not prefix then
    return
  end
  local new = mark == " " and "x" or " "
  vim.fn.setline(lnum, prefix .. new .. line:sub(#prefix + 2))
end

vim.keymap.set("n", "<leader><space>", function()
  toggle_checkbox(vim.fn.line("."))
end, { buffer = true, silent = true, desc = "Toggle checkbox" })

vim.keymap.set("x", "<leader><space>", function()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  if s > e then
    s, e = e, s
  end
  for lnum = s, e do
    toggle_checkbox(lnum)
  end
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
end, { buffer = true, silent = true, desc = "Toggle checkboxes" })
