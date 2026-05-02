return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local servers = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "pyright",
                "ts_ls",
                "bashls",
                "yamlls",
                "jsonls",
                "html",
                "cssls",
                "dockerls",
                "marksman",
            }

            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_installation = true,
            })

            require("mason-tool-installer").setup({
                ensure_installed = {
                    "stylua",
                    "shellcheck",
                    "shfmt",
                    "eslint_d",
                    "ruff",
                    "yamllint",
                    "jsonlint",
                    "hadolint",
                },
                run_on_start = true,
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("*", { capabilities = capabilities })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            vim.lsp.enable(servers)

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
                callback = function(ev)
                    local map = function(keys, fn, desc)
                        vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
                    end
                    map("gd", vim.lsp.buf.definition, "Goto definition")
                    map("gD", vim.lsp.buf.declaration, "Goto declaration")
                    map("gr", vim.lsp.buf.references, "References")
                    map("gi", vim.lsp.buf.implementation, "Goto implementation")
                    map("gt", vim.lsp.buf.type_definition, "Goto type definition")
                    map("K", vim.lsp.buf.hover, "Hover")
                    map("<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("<leader>F", function() vim.lsp.buf.format({ async = true }) end, "Format")
                    map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
                    map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
                    map("<leader>e", vim.diagnostic.open_float, "Show line diagnostic")
                end,
            })

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded", source = true },
            })
        end,
    },
}
