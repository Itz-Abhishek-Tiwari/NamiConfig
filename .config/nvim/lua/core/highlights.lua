-- Standard highlight groups
local function set_highlights()
  local ok, gruvbox = pcall(require, "gruvbox")
  if not ok then return end
  
  local colors = gruvbox.palette
  local is_dark = vim.o.background == "dark"
  
  -- Choose base colors based on background
  local bg0 = is_dark and colors.dark0_hard or colors.light0_hard
  local fg0 = is_dark and colors.light0 or colors.dark0
  local orange = colors.bright_orange
  local green = colors.bright_green
  local yellow = colors.bright_yellow
  local blue = colors.bright_blue
  local bg_soft = is_dark and colors.dark1 or colors.light1

  -- Gruvbox-friendly UI overrides
  local highlights = {
    -- Global Background
    Normal = { bg = bg0 },
    NormalFloat = { bg = bg0 },
    FloatBorder = { bg = bg0, fg = fg0 },
    
    -- Telescope
    TelescopeNormal = { bg = bg0 },
    TelescopeBorder = { bg = bg0, fg = fg0 },
    TelescopePromptNormal = { bg = bg0 },
    TelescopePromptBorder = { bg = bg0, fg = orange },
    TelescopeResultsNormal = { bg = bg0 },
    TelescopeResultsBorder = { bg = bg0, fg = fg0 },
    TelescopePreviewNormal = { bg = bg0 },
    TelescopePreviewBorder = { bg = bg0, fg = fg0 },
    TelescopePromptPrefix = { fg = orange },
    
    -- Noice
    NoiceCmdlinePopupBorder = { fg = orange },
    NoiceCmdlineIcon = { fg = orange },
    
    -- Indent Blankline
    IblIndent = { fg = bg_soft },
    IblScope = { fg = orange },

    -- CMP
    CmpItemAbbrMatch = { fg = orange, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = orange, bold = true },
    CmpItemKindText = { fg = fg0 },
    CmpItemKindMethod = { fg = green },
    CmpItemKindFunction = { fg = green },
    CmpItemKindConstructor = { fg = yellow },
    CmpItemKindField = { fg = blue },
    CmpItemKindVariable = { fg = blue },
  }

  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Hook into colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_highlights,
})

-- Apply once now
set_highlights()
