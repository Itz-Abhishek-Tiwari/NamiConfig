local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")

local opts = {
  sources = {
    -- Python sources
    null_ls.builtins.formatting.black, -- Python formatting

    -- HTML/Django sources (optional)
    -- null_ls.builtins.formatting.prettier.with({
    --   filetypes = { "html", "htmldjango" },
    -- }),

    -- Add Prettier for JSX formatting
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }, -- Add relevant filetypes
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
}

return opts
