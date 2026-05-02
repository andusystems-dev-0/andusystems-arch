return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                rust = { "clippy" },
                python = { "ruff" },
                sh = { "shellcheck" },
                bash = { "shellcheck" },
                yaml = { "yamllint" },
                json = { "jsonlint" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                dockerfile = { "hadolint" },
            }

            local function try_lint()
                local ft = vim.bo.filetype
                local configured = lint.linters_by_ft[ft]
                if not configured then return end
                local available = {}
                for _, name in ipairs(configured) do
                    local linter = lint.linters[name]
                    local cmd = type(linter) == "table" and linter.cmd or nil
                    if type(cmd) == "function" then cmd = cmd() end
                    if cmd and vim.fn.executable(cmd) == 1 then
                        table.insert(available, name)
                    end
                end
                if #available > 0 then
                    lint.try_lint(available)
                end
            end

            local group = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = group,
                callback = try_lint,
            })
        end,
    },
}
