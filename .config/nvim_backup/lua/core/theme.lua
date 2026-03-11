local M = {}

local state_file = vim.fn.expand("~/.cache/current-theme")
M.watcher = nil -- Module-level variable to prevent GC

function M.apply_theme()
  local f = io.open(state_file, "r")
  if f then
    local theme = f:read("*all"):gsub("%s+", "")
    f:close()
    if theme == "dark" or theme == "light" then
      if vim.o.background ~= theme then
        vim.o.background = theme
        -- Explicitly re-apply colorscheme to ensure all highlights are refreshed
        pcall(vim.cmd, "colorscheme gruvbox")
        
        -- Refresh UI components that might not auto-sync
        vim.schedule(function()
          -- Refresh NvimTree highlights
          local ok_nt, nt = pcall(require, "nvim-tree.view")
          if ok_nt and nt.is_visible() then
            vim.cmd("NvimTreeRefresh")
          end
          
          -- Refresh Bufferline colors
          pcall(vim.cmd, "BufferLineTabpages") -- Dummy call to force redraw/refresh if needed
        end)
      end
    end
  end
end

function M.toggle()
  local current = vim.o.background
  local new = current == "dark" and "light" or "dark"
  
  -- Update the state file
  local f = io.open(state_file, "w")
  if f then
    f:write(new)
    f:close()
  end
  
  -- Apply immediately
  vim.o.background = new
  pcall(vim.cmd, "colorscheme gruvbox")
  vim.notify("Theme toggled to " .. new)
end

function M.setup()
  -- Initial apply
  M.apply_theme()

  -- Stop existing watcher if setup is called again
  if M.watcher then
    M.watcher:stop()
  end

  -- Watch for changes
  M.watcher = vim.loop.new_fs_event()
  if M.watcher then
    -- Watch the directory instead of the file for better event handling
    local state_dir = vim.fn.fnamemodify(state_file, ":h")
    M.watcher:start(state_dir, {}, vim.schedule_wrap(function(err, filename, events)
      if err then return end
      -- Only trigger if the target file changed
      if filename == vim.fn.fnamemodify(state_file, ":t") then
        M.apply_theme()
      end
    end))
  end
end

return M
