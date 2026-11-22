-- Line picker for fzf-file-mention. Loaded into `NVIM_MINIMAL=1 nvim -M`,
-- in a popup over the fzf pane, which shows again when nvim quits.
--
--   <CR> in visual mode  add "<path>#L<start>-<end>" and quit
--   <CR> in normal mode  add "<path>#L<line>" and quit
--   q                    quit without adding
--
-- A range is appended to $FZF_MENTION_DIR/ranges, which fzf follows, so it
-- shows up as a new entry at the top of the list. Before quitting, nvim runs
-- `$FZF_MENTION_MAIN select`, which selects that entry in fzf and puts the
-- cursor back on $FZF_MENTION_ENTRY, so fzf is up to date once the popup
-- closes.

local dir = os.getenv("FZF_MENTION_DIR")
local main = os.getenv("FZF_MENTION_MAIN")
local entry = os.getenv("FZF_MENTION_ENTRY") or ""
local path = vim.fn.expand("%")

vim.bo.modifiable = false
vim.bo.readonly = true
vim.wo.number = true

local function finish(ref)
  if ref and dir then
    vim.fn.writefile({ ref }, dir .. "/ranges", "a")
    if main then
      vim.system({ main, "select", dir, ref, entry }):wait(2000)
    end
  end
  vim.cmd("qa!")
end

local function ref(s, e)
  if s > e then
    s, e = e, s
  end
  if s == e then
    return ("%s#L%d"):format(path, s)
  end
  return ("%s#L%d-%d"):format(path, s, e)
end

vim.keymap.set("x", "<CR>", function()
  finish(ref(vim.fn.line("v"), vim.fn.line(".")))
end, { buffer = true })

vim.keymap.set("n", "<CR>", function()
  local l = vim.fn.line(".")
  finish(ref(l, l))
end, { buffer = true })

vim.keymap.set("n", "q", function()
  finish(nil)
end, { buffer = true })
