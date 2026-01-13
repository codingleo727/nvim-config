*As of update, check if you would like the "main" branch of nvim-treesitter or the "master" branch of nvim-treesitter. My current setup uses the "main" branch of nvim-treesitter*

# Neovim Configuration for Systems Programming

A performance-oriented Neovim configuration written entirely in **Lua**. Designed specifically for C/C++ development workflows, featuring integrated compilation, linting, and LSP support.

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)

## Features
* **Package Management:** Powered by `lazy.nvim` for fast startup times.
* **LSP Integration:** Full support for C/C++ (`clangd`), Python (`pyright`), and Lua (`lua_ls`) via Mason.
* **Intelligent Completion:** `nvim-cmp` with snippet support (`LuaSnip`).
* **Systems Workflow:** Custom compiler bindings for GCC/G++ with strict warning flags (`-Wall -Wextra -Wpedantic`).
* **Formatting:** Integrated `clang-format` support.

## Prerequisites
* Neovim >= 0.9.0
* Git
* A C/C++ Compiler (GCC/Clang)
* Rippgrep (optional, for grep searching)

## Installation

**1. Back up your current configuration**
```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

**2. Clone this repository**
```bash
git clone [https://github.com/YOUR_USERNAME/nvim-config.git](https://github.com/codingleo727/nvim-config.git) ~/.config/nvim

**3. Start Neovim**
Open nvim. The lazy.nvim manager will automatically bootstrap and install all plugins
