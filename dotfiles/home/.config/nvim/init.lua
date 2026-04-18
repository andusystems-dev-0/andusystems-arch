-- Leader keys (must be set before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
    vim.cmd("qa!")
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/
require("lazy").setup("plugins", {
  change_detection = { notify = false },
})

-- Load project terminal autocmds
require("config.autocmds")

-- Terminal: always open by default, <leader>t to focus/unfocus
local terminal_buf = nil
local terminal_win = nil

local function open_terminal()
  vim.cmd("botright 15split")
  terminal_win = vim.api.nvim_get_current_win()
  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    vim.api.nvim_win_set_buf(terminal_win, terminal_buf)
  else
    vim.cmd("terminal")
    terminal_buf = vim.api.nvim_get_current_buf()
  end
end

vim.keymap.set("n", "<leader>t", function()
  -- If terminal window exists and we're in it, go back to previous window
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    if vim.api.nvim_get_current_win() == terminal_win then
      vim.cmd("wincmd p")
    else
      vim.api.nvim_set_current_win(terminal_win)
    end
  else
    open_terminal()
  end
end, { desc = "Focus/unfocus terminal" })

-- Escape to go back to normal mode in terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Open terminal on startup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      open_terminal()
      -- Return focus to editor
      vim.cmd("wincmd p")
    end)
  end,
})

-- Open lazygit in a floating window
vim.keymap.set("n", "<leader>gg", function()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen("lazygit", {
    on_exit = function()
      vim.api.nvim_win_close(0, true)
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Open lazygit" })
