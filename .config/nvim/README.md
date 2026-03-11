# Neovim Configuration

A modern, Lua-based Neovim configuration inspired by NvChad but customized for performance and the Gruvbox aesthetic.

## Structure

- `init.lua`: Main entry point.
- `lua/`:
    - `core/`: Basic Vim settings and options.
    - `plugins/`: Plugin configurations (Lazy.nvim).
    - `configs/`: LSP and tool-specific configurations.
    - `chadrc.lua`: UI-specific customizations.

## Key Plugins

- **Lazy.nvim**: Plugin manager.
- **Nvim-Treesitter**: Syntax highlighting and AST.
- **Nvim-LSPConfig**: Language Server Protocol setup.
- **Conform.nvim**: Code formatting.
- **Nvim-Cmp**: Completion engine.
- **Telescope.nvim**: Fuzzy finder.
- **Nvim-Tree**: File explorer.

## Usage

Use the standard Neovim keybindings. Custom mappings are defined in the plugin configuration files within `lua/plugins/`.
