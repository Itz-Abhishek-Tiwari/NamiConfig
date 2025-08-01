# My Custom Neovim Setup (NvChad)

This repository contains my customized Neovim configuration using [NvChad](https://github.com/NvChad/NvChad), tailored for web development with support for Python, Django, React, and Vue. It also includes powerful debugging capabilities for Python through `nvim-dap`.

## Features

- **NvChad Configuration**: A pre-configured Neovim setup that is modular and extensible.
- **Language Support**:
  - **Python**: Enhanced editing experience with LSP and autocompletion.
  - **Django**: Django-specific enhancements for a smoother development workflow.
  - **React**: Support for JSX syntax highlighting and code snippets.
  - **Vue**: Syntax highlighting and autocompletion for Vue components.
- **Debugging**: Integrated Python debugging with `nvim-dap`.

## Installation

1. **Install Neovim**: Ensure you have Neovim 0.7 or higher installed. Follow the [installation instructions here](https://github.com/neovim/neovim/wiki/Installing-Neovim).
   
2. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/nvchad-config.git ~/.config/nvim

3. **Install Plugins**: Open Neovim and run:
   ```vim
   :PackerInstall
   ```

4. **Setup Python Debugger**:
   Ensure you have the required dependencies installed. You can install `nvim-dap` and any necessary adapters for Python. Here’s a quick setup guide:
   ```bash
   pip install debugpy
   ```

5. **Configuration**:
   Customize the configuration files as needed. Check the `lua` directory for additional settings.

## Usage

- Launch Neovim and open your desired project.
- Use the following commands for debugging:
  - Start debugging: `:lua require'dap'.continue()`
  - Set a breakpoint: `:lua require'dap'.toggle_breakpoint()`
  - Step into: `:lua require'dap'.step_into()`
  - Step out: `:lua require'dap'.step_out()`

## Contributing

Feel free to contribute by forking the repository and submitting pull requests. Any feedback or suggestions are welcome!

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

## Acknowledgements

- [NvChad](https://github.com/NvChad/NvChad)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)

