return {
  -- UI & Appearance
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("core.theme")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "gruvbox",
        globalstatus = true,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { 
          statusline = { "dashboard", "alpha", "NvimTree", "toggleterm" },
          winbar = { "dashboard", "alpha", "NvimTree", "toggleterm" },
        },
      },
      sections = {
        lualine_a = { 
          { 
            "mode", 
            color = { bg = "#fe8019", fg = "#1d2021", gui = "bold" },
          } 
        },
        lualine_b = { 
          { 
            "branch", 
            icon = "", 
            color = { bg = "#3c3836", fg = "#ebdbb2" },
          },
          { 
            "filename", 
            file_status = true, 
            path = 0, 
            color = { bg = "#504945", fg = "#ebdbb2" },
            cond = function() return vim.bo.filetype ~= "toggleterm" end
          },
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
          },
        },
        lualine_x = {
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "No LSP" end
              return clients[1].name
            end,
            icon = "",
            color = { fg = "#fe8019", gui = "bold" },
          },
        },
        lualine_y = { 
          { 
            "progress", 
            color = { bg = "#3c3836", fg = "#ebdbb2" },
          } 
        },
        lualine_z = {
          { 
            "location", 
            color = { bg = "#fe8019", fg = "#1d2021", gui = "bold" } ,
          },
        },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.minimal,
          separator_style = "thick",
          show_buffer_close_icons = false,
          show_close_icon = false,
          diagnostics = "nvim_lsp",
          custom_filter = function(buf_number)
            -- Hide toggleterm and NvimTree from bufferline
            local ft = vim.bo[buf_number].filetype
            if ft == "toggleterm" or ft == "NvimTree" then
              return false
            end
            return true
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "EXPLORER",
              text_align = "center",
              separator = true,
            },
          },
        },
      }
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      filters = { dotfiles = false },
      view = {
        side = "left",
        width = 30,
      },
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      git = {
        enable = true,
        ignore = false,
      },
    },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        "                                ",
        "  ██████   ██████  ██████  ██ ██  ",
        "  ██   ██ ██    ██ ██   ██ ██ ██  ",
        "  ██████  ██    ██ ██████  ██ ██  ",
        "  ██   ██ ██    ██ ██   ██ ██     ",
        "  ██████   ██████  ██   ██ ██ ██  ",
        "                                ",
        "      [ Neovim 0.11 Optimized ] ",
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("r", "󰄉  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "󰱼  Find text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
        dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "󰗼  Quit", ":qa<CR>"),
      }
      alpha.setup(dashboard.opts)
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.styled_pairstack"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#222526",
        fps = 30,
        icons = {
          DEBUG = "",
          ERROR = "",
          INFO = "",
          TRACE = "✎",
          WARN = ""
        },
        level = 2,
        minimum_width = 50,
        render = "default",
        stages = "fade_in_slide_out",
        timeout = 5000,
        top_down = true
      })
      vim.notify = notify
    end,
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
}
