-- Modular init.lua
-- NvChad-inspired, optimized for full-stack

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46_cache/"

-- Set leader key
vim.g.mapleader = " "

-- Load core modules
require("core.options")
require("core.keymaps")
require("core.theme").setup()
require("core.reload").setup()

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")

-- Load custom highlights
require("core.highlights")

-- Apply theme
vim.cmd([[colorscheme gruvbox]])
