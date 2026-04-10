return {
  {
    "echasnovski/mini.base16",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      local ok, palette = pcall(require, "colors.matugen")
      if not ok then return end
      require("mini.base16").setup({ palette = palette })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "mini-base16" },
  },
}
