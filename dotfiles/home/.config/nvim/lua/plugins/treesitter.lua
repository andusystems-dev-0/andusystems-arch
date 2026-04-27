return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "yaml", "go", "rust", "bash", "lua", "vim", "vimdoc" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
}
