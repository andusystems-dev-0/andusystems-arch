return {
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedarkpro").setup({})
      vim.cmd("colorscheme onedark_dark")
    end,
  },
}
