vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"


-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

vim.schedule(function()
  require "mappings"
end)

-- user added
vim.opt.swapfile = false
vim.opt.colorcolumn = "80"
vim.opt.mouse = ""

-- custom key to move line
vim.api.nvim_set_keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true, silent = true })

--padding neovid
vim.g.neovide_padding_top = 40
vim.g.neovide_padding_bottom = 40
vim.g.neovide_padding_right = 40
vim.g.neovide_padding_left = 40

local hardmode = true
if hardmode then
  -- Show an error message if a disabled key is pressed
  local msg = [[<cmd>echohl Error | echo "KEY DISABLED" | echohl None<CR>]]

  -- Disable arrow keys in insert mode with a styled message
  vim.api.nvim_set_keymap("i", "<Up>", "<C-o>" .. msg, { noremap = true, silent = false })
  vim.api.nvim_set_keymap("i", "<Down>", "<C-o>" .. msg, { noremap = true, silent = false })
  vim.api.nvim_set_keymap("i", "<Left>", "<C-o>" .. msg, { noremap = true, silent = false })
  vim.api.nvim_set_keymap("i", "<Right>", "<C-o>" .. msg, { noremap = true, silent = false })
  -- vim.api.nvim_set_keymap('i', '<Del>', '<C-o>' .. msg, { noremap = true, silent = false })
  -- vim.api.nvim_set_keymap('i', '<BS>', '<C-o>' .. msg, { noremap = true, silent = false })

  -- Disable arrow keys in normal mode with a styled message
  vim.api.nvim_set_keymap("n", "<Up>", msg, { noremap = true, silent = false })
  vim.api.nvim_set_keymap("n", "<Down>", msg, { noremap = true, silent = false })
  vim.api.nvim_set_keymap("n", "<Left>", msg, { noremap = true, silent = false })
  vim.api.nvim_set_keymap("n", "<Right>", msg, { noremap = true, silent = false })
  -- vim.api.nvim_set_keymap('n', '<BS>', msg, { noremap = true, silent = false })
end

-- html python venv
-- Function to check if we're in a Python virtual environment
local function in_virtual_env()
  local venv = os.getenv("VIRTUAL_ENV")
  return venv ~= nil
end

-- Conditional autocommand based on virtual environment
if in_virtual_env() then
  vim.cmd([[
    augroup FileTypeDjango
      autocmd!
      autocmd BufNewFile,BufRead *.html set filetype=htmldjango
    augroup END
  ]])
end

-- git blame nvim
