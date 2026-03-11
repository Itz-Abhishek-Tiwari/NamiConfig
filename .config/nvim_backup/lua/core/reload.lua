local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.fn.expand("~/.config/nvim/**/*.lua"),
    callback = function(opts)
      local file = opts.file
      
      -- Reload the specific file
      -- Note: This is a simple reload. Complex plugin changes might still require a restart.
      local ok, err = pcall(dofile, file)
      
      if ok then
        vim.notify("Config reloaded: " .. vim.fn.fnamemodify(file, ":t"), vim.log.levels.INFO)
      else
        vim.notify("Error reloading " .. file .. ": " .. err, vim.log.levels.ERROR)
      end
    end,
    group = vim.api.nvim_create_augroup("ConfigReload", { clear = true }),
  })
end

return M
