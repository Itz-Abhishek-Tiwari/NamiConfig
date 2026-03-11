return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "python",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "json",
          "lua",
          "bash",
          "markdown",
          "markdown_inline",
          "yaml",
        },
        highlight = { enable = true },
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}
