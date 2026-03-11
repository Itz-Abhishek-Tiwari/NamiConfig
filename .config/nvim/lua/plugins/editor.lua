return {
  -- Editor Utilities

  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },

  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
  },

  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          use_treesitter = true,
        },
        indent = {
          enable = true,
          use_treesitter = true,
        },
      })
    end,
  },

  {
    "RRethy/vim-illuminate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("illuminate").configure()
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<C-\>]], mode = { "n", "t" }, desc = "Toggle Terminal" },
      { "<A-h>", "<cmd>ToggleTerm direction=horizontal<cr>", mode = { "n", "t" }, desc = "Horizontal Terminal" },
      { "<A-v>", "<cmd>ToggleTerm direction=vertical<cr>", mode = { "n", "t" }, desc = "Vertical Terminal" },
      { "<A-i>", "<cmd>ToggleTerm direction=float<cr>", mode = { "n", "t" }, desc = "Float Terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = false,
      highlights = {
        Normal = { link = "Normal" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
      },
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "horizontal",
      close_on_exit = true,
      shell = vim.o.shell,
    },
  },

  {
    "Pocco81/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      execution_message = {
        message = function() return ("AutoSave: saved at " .. vim.fn.strftime("%I:%M:%S %p")) end,
        dim = 0.18,
        cleaning_interval = 1250,
      },
      trigger_events = { "InsertLeave", "TextChanged" },
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
          return true
        end
        return false
      end,
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { 
        char = "▏",
        tab_char = "▏",
      },
      scope = { 
        enabled = true,
        show_start = false,
        show_end = false,
        highlight = { "GruvboxOrange", "GruvboxRed", "GruvboxYellow", "GruvboxGreen", "GruvboxAqua", "GruvboxBlue", "GruvboxPurple" },
      },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard", "nvim-tree", "Trouble", "lazy", "mason", "notify", "toggleterm", "lazyterm",
        },
      },
    },
  },
}
