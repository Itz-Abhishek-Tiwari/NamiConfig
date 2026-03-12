local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- Set up lspconfig.
local capabilities = cmp_nvim_lsp.default_capabilities()

local on_attach = function(client, bufnr)
    -- Formatting is handled by LSP, but for JS/TS we might use eslint instead of tsserver formatting
    if client.name == "tsserver" or client.name == "ts_ls" then
        client.server_capabilities.documentFormattingProvider = false
    end
end

-- Server Setup using the new Neovim 0.11+ API
-- This avoids the deprecated 'require("lspconfig")' framework
-- Modern Neovim 0.11+ way to setup servers
-- use vim.lsp.config which is the new officially recommended API
-- and avoids the deprecated nvim-lspconfig framework warnings
local function setup_server(name, opts)
    opts = opts or {}
    opts.capabilities = capabilities
    opts.on_attach = on_attach
    
    -- Standardize borders for diagnostic and hover floats
    opts.handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
    }

    vim.lsp.config(name, opts)
end

-- UI Improvements for diagnostics
vim.diagnostic.config({
  float = { border = "rounded" },
})

-- Python
setup_server("pyright")
setup_server("ruff")

-- React/React Native (JavaScript/TypeScript)
setup_server("ts_ls")
setup_server("tailwindcss")

setup_server("eslint", {
    settings = {
        workingDirectory = { mode = "auto" },
    },
})

-- Bash
setup_server("bashls")

-- JSON
setup_server("jsonls")

-- HTML & CSS
setup_server("html")
setup_server("cssls")
setup_server("emmet_ls")

-- Hyprland
setup_server("hyprls")
