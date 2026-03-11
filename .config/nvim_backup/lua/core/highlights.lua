-- Standard highlight groups
local function set_highlights()
  -- Gruvbox-friendly UI overrides
  local highlights = {
    -- Global Background
    Normal = { bg = "#222526" },
    NormalFloat = { bg = "#222526" },
    FloatBorder = { bg = "#222526", fg = "#ebdbb2" },
    
    -- Telescope
    TelescopeNormal = { bg = "#222526" },
    TelescopeBorder = { bg = "#222526", fg = "#ebdbb2" },
    TelescopePromptNormal = { bg = "#222526" },
    TelescopePromptBorder = { bg = "#222526", fg = "#fe8019" },
    TelescopeResultsNormal = { bg = "#222526" },
    TelescopeResultsBorder = { bg = "#222526", fg = "#ebdbb2" },
    TelescopePreviewNormal = { bg = "#222526" },
    TelescopePreviewBorder = { bg = "#222526", fg = "#ebdbb2" },
    TelescopePromptPrefix = { fg = "#fe8019" },
    
    -- Noice
    NoiceCmdlinePopupBorder = { fg = "#fe8019" },
    NoiceCmdlineIcon = { fg = "#fe8019" },
    
    -- Indent Blankline
    IblIndent = { fg = "#3c3836" },
    IblScope = { fg = "#fe8019" },

    -- CMP
    CmpItemAbbrMatch = { fg = "#fe8019", bold = true },
    CmpItemAbbrMatchFuzzy = { fg = "#fe8019", bold = true },
    CmpItemKindText = { fg = "#ebdbb2" },
    CmpItemKindMethod = { fg = "#b8bb26" },
    CmpItemKindFunction = { fg = "#b8bb26" },
    CmpItemKindConstructor = { fg = "#fabd2f" },
    CmpItemKindField = { fg = "#83a598" },
    CmpItemKindVariable = { fg = "#83a598" },
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
