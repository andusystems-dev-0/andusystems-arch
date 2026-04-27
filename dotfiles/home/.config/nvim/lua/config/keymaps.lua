local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

local function find_win_by_filetype(ft)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == ft then
            return win
        end
    end
end

map("n", "<leader>f", function()
    local win = find_win_by_filetype("neo-tree")
    if not win then return end
    if vim.api.nvim_get_current_win() == win then
        vim.cmd("wincmd p")
    else
        vim.api.nvim_set_current_win(win)
    end
end, { desc = "Focus/unfocus neo-tree" })

map("n", "<leader>ff", function()
    local win = find_win_by_filetype("neo-tree")
    if win then
        vim.cmd("Neotree close")
    else
        vim.cmd("Neotree show")
    end
end, { desc = "Toggle neo-tree" })

local function find_terminal_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
            return win
        end
    end
end

local function find_terminal_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
            return buf
        end
    end
end

map("n", "<leader>t", function()
    local win = find_terminal_win()
    if not win then return end
    if vim.api.nvim_get_current_win() == win then
        vim.cmd("wincmd p")
    else
        vim.api.nvim_set_current_win(win)
        vim.cmd("startinsert")
    end
end, { desc = "Focus/unfocus terminal" })

map("n", "<leader>tt", function()
    local win = find_terminal_win()
    if win then
        vim.api.nvim_win_close(win, false)
        return
    end
    local buf = find_terminal_buf()
    vim.cmd("botright 15split")
    if buf then
        vim.cmd("buffer " .. buf)
    else
        vim.cmd("terminal")
    end
    vim.cmd("startinsert")
end, { desc = "Toggle terminal" })
