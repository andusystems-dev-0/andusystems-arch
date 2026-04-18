-- Project terminals: opens two side-by-side terminal splits at the bottom
-- when nvim is opened in the project directory.
-- Left: [AI_ASSISTANT], Right: shell.

local PROJECT_DIR = "/home/admin/andusystems-arch"

local function open_project_terminals()
  vim.cmd("botright 22split")
  vim.cmd("vsplit")
  -- Right pane: shell
  vim.cmd("terminal")
  -- Left pane: [AI_ASSISTANT]
  vim.cmd("wincmd h")
  vim.cmd("terminal [AI_ASSISTANT] --dangerously-skip-permissions")
  -- Return focus to editor
  vim.cmd("wincmd k")
end

local function close_project_terminals()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end

local function toggle_project_terminals()
  local has_term = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
      has_term = true
      break
    end
  end
  if has_term then
    close_project_terminals()
  else
    open_project_terminals()
  end
end

vim.keymap.set("n", "<leader>tt", toggle_project_terminals, { desc = "Toggle project terminals" })

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("andusystems_terminals", { clear = true }),
  callback = function()
    if vim.fn.getcwd() ~= PROJECT_DIR then return end
    local args = vim.fn.argv()
    if #args > 0 and vim.fn.isdirectory(tostring(args[1])) == 0 then return end
    vim.defer_fn(open_project_terminals, 300)
  end,
})
