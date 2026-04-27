local group = vim.api.nvim_create_augroup("user_startup", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
        vim.cmd("Neotree show")
    end,
})
