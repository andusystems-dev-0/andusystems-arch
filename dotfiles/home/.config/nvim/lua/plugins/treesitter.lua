return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    main = "nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "dockerfile",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "yaml",
      },
      auto_install = true,
    },
  },
}
