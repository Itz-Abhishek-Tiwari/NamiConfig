--@type ChadrcConfig
local M = {}


M.base46 = {
  theme = "catppuccin",
  transparency = true,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.ui = {
  tabufline = {
    order = { "treeOffset", "buffers", "tabs", "btns" },
  },

  telescope = {
    style = "borderless",
    layout_strategy = "vertical"
  },

  colorify = {
    enabled = true,
    mode = "fg", -- fg, bg, virtual
    highlight = { hex = true, lspvars = true },
  },

  cmp = {
    lspkind_text = true,
    style = "atom_colored",
    format_colors = {
      lsp = true,
    },
  },
  statusline = {
    theme = "default",
    separator_style = "block",
  }
}


M.mason = {
  pkgs = {
    -- Web Dev
    "emmet-language-server",
    "html-lsp",
    "css-lsp",
    "json-lsp",
    "tailwindcss-language-server",
    "typescript-language-server",
    "vue-language-server",
    "unocss-language-server",
    "eslint-lsp",
    "prettier",

    -- Lua
    "lua-language-server",
    "stylua",

    -- Python
    "pyright",
    "ruff-lsp",
    "mypy",
    "flake8",
    "black",
    "pylint",
    "debugpy",

    -- Shell & SQL
    "bash-language-server",
    "sqls",

    -- Markup
    "marksman", -- Markdown
    "djlint",   -- Django/Jinja templates
    "jinja-lsp",

    -- YAML/TOML/etc
    "yaml-language-server",
    "taplo", -- TOML

    -- Docker, Git, etc.
    "dockerfile-language-server",
    "docker-compose-language-service",
    "gopls", -- in case of Go support
    "qmlls"
  }
}

-- vim.cmd([[
--   augroup FileTypeDjango
--     autocmd!
--     autocmd BufNewFile,BufRead *.html set filetype=htmldjango
--   augroup END
-- ]])
return M
