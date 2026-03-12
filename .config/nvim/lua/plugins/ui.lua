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
    dependencies = { "nvim-tree/nvim-web-devicons", "ellisonleao/gruvbox.nvim" },
    event = "VeryLazy",
    opts = function()
      local colors = require("gruvbox").palette
      return {
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
              color = { bg = colors.bright_orange, fg = colors.dark0, gui = "bold" },
            } 
          },
          lualine_b = { 
            { 
              "branch", 
              icon = "", 
              color = { bg = colors.dark2, fg = colors.light1 },
            },
            { 
              "filename", 
              file_status = true, 
              path = 0, 
              color = { bg = colors.dark3, fg = colors.light1 },
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
              color = { fg = colors.bright_orange, gui = "bold" },
            },
          },
          lualine_y = { 
            { 
              "progress", 
              color = { bg = colors.dark2, fg = colors.light1 },
            } 
          },
          lualine_z = {
            { 
              "location", 
              color = { bg = colors.bright_orange, fg = colors.dark0, gui = "bold" } ,
            },
          },
        },
      }
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons", "ellisonleao/gruvbox.nvim" },
    event = "VeryLazy",
    opts = function()
      local colors = require("gruvbox").palette
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
        highlights = {
          fill = { bg = colors.dark0_hard },
          background = { bg = colors.dark0_hard, fg = colors.gray },
          buffer_selected = { bg = colors.dark1, fg = colors.light0, bold = true },
          separator_selected = { bg = colors.dark1, fg = colors.dark1 },
          separator_visible = { bg = colors.dark0_hard, fg = colors.dark0_hard },
          separator = { bg = colors.dark0_hard, fg = colors.dark0_hard },
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
        "  ███    ██  █████  ███    ███ ██ ",
        "  ████   ██ ██   ██ ████  ████ ██ ",
        "  ██ ██  ██ ███████ ██ ████ ██ ██ ",
        "  ██  ██ ██ ██   ██ ██  ██  ██ ██ ",
        "  ██   ████ ██   ██ ██      ██ ██ ",
        "                                ",
        "      [ NamiConfig Optimized ] ",
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
        minimum_width = 20,
        render = "default",
        stages = "fade_in_slide_out",
        timeout = 3000,
        top_down = false
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
