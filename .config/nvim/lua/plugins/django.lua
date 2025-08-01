return {
  -- Django template syntax highlighting
  {
    "lepture/vim-jinja",
    ft = { "htmldjango", "html" },
  },

  -- Enhanced Django support
  {
    "tweekmonster/django-plus.vim",
    ft = { "htmldjango", "python" },
    config = function()
      -- Plugin specific configuration
    end,
    cond = function()
      return vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 1
    end,
  },
}
