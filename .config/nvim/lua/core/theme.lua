local M = {}

local state_file = vim.fn.expand("~/.cache/current-theme")
M.watcher = nil -- Module-level variable to prevent GC

function M.apply_theme()
  local f = io.open(state_file, "r")
  if f then
    local theme = f:read("*all"):gsub("%s+", "")
    f:close()
    if (theme == "dark" or theme == "light") and vim.o.background ~= theme then
      vim.o.background = theme
      -- Trigger colorscheme re-apply to refresh all highlights (including our dynamic ones)
      vim.cmd("colorscheme gruvbox")
      
      -- Refresh plugins that need manual poke after color change
      vim.schedule(function()
        pcall(function() require("lualine").setup() end)
        pcall(function() require("bufferline").setup() end)
      end)
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
