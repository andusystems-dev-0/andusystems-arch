return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                rust = { "clippy" },
            }

            local group = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
            vim.api.nvim_create_autocmd("BufWritePost", {
                group = group,
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end,
    },
}
