local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- List of servers with default configuration
local servers = { "html", "volar", "cssls", "ts_ls", "tailwindcss", "eslint", "sqls", "texlab", "jsonls",
  "pyright","unocss" }

-- Cssls
lspconfig.cssls.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "css" },
})




-- Markdown
lspconfig.marksman.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "markdown" },
})


-- Setup LSP servers with default configuration
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

-- TypeScript
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
})

-- Vue.js
lspconfig.volar.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "vue" },
})

-- Python
lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "python" },
})

-- HTML
lspconfig.html.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "htmldjango" },
})

-- Emmet Language Server
lspconfig.emmet_language_server.setup({
  filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact", "htmldjango" },
  init_options = {
    includeLanguages = {},
    excludeLanguages = {},
    extensionsPath = {},
    preferences = {},
    showAbbreviationSuggestions = true,
    showExpandedAbbreviation = "always",
    showSuggestionsAsSnippets = false,
    syntaxProfiles = {},
    variables = {},
  },
})
