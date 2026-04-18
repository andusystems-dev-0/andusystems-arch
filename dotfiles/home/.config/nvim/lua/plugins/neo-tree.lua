return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
      window = {
        mappings = {
          ["l"] = "open",
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
    init = function()
      -- <leader>ff to toggle open/close
      vim.keymap.set("n", "<leader>ff", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neo-tree" })
      -- <leader>f to focus/unfocus
      vim.keymap.set("n", "<leader>f", function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        if ft == "neo-tree" then
          vim.cmd("wincmd p")
        else
          vim.cmd("Neotree focus")
        end
      end, { desc = "Focus/unfocus Neo-tree" })

      -- Open on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          vim.schedule(function()
            vim.cmd("Neotree show")
          end)
        end,
      })
    end,
  },
}
