-- ================= Plugins (lazy.nvim) =================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.termguicolors = true
local plugins = {
  -- Treesitter (modern syntax & structure)
  { "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "c", "cpp", "lua", "vim", "python" },
      highlight = { enable = true },
      indent = { enable = true, disable = {"python"} },
  }},

  -- LSP core + installer
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  -- Completion stack (nvim-cmp + LSP source + snippets)
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- Your file tree (kept)
  "preservim/nerdtree",

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night" },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}

require("lazy").setup(plugins, {
  rocks = { enabled = false, hererocks = false },
})

-- ================= Basics =================
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

local o = vim.opt
o.number       = true
o.tabstop      = 2
o.shiftwidth   = 2
o.softtabstop  = 2
o.expandtab    = true

o.autoindent   = true
o.smartindent  = true
o.smarttab     = true
o.ruler        = true
o.splitright   = true
o.splitbelow   = true
o.wrap         = false
o.ignorecase   = true
o.smartcase    = true
o.undofile     = true

vim.api.nvim_set_hl(0, "LineNr", { fg = "#f5de9c" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFFFFF", bold = true })

-- ================= Completion (nvim-cmp) =================
local ok_cmp, cmp = pcall(require, "cmp")
local ok_snip, luasnip = pcall(require, "luasnip")

if ok_cmp and ok_snip then
  cmp.setup({
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"]      = cmp.mapping.confirm({ select = true }),
      ["<Tab>"]     = cmp.mapping.select_next_item(),
      ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
    }),
    sources = {
      { name = "nvim_lsp" },
      { name = "buffer" },
      { name = "path" },
    },
  })
end

-- ================= LSP (mason + lspconfig) =================
local ok_mason, mason = pcall(require, "mason")
local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
local ok_cmpcap, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if ok_mason then mason.setup() end

if ok_mlsp then
  mason_lspconfig.setup({
    ensure_installed = { "clangd", "pyright", "lua_ls" },
    automatic_installation = true,
  })
end

local capabilities = nil
if ok_cmpcap then
  capabilities = cmp_nvim_lsp.default_capabilities()
end

-- Keymaps per LSP buffer
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
  end
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gD", vim.lsp.buf.declaration)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "K",  vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
  map("n", "[d", vim.diagnostic.goto_prev)
  map("n", "]d", vim.diagnostic.goto_next)
  map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end)
end

local function setup_server(name, cfg)
  if vim.lsp and vim.lsp.config and vim.lsp.enable then
    -- Neovim 0.11+
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
  else
    -- Neovim 0.10 and older (use nvim-lspconfig)
    local lspconfig = require("lspconfig")
    lspconfig[name].setup(cfg)
  end
end

setup_server("clangd", { on_attach = on_attach, capabilities = capabilities })
setup_server("pyright", { on_attach = on_attach, capabilities = capabilities })
setup_server("lua_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- ================= pyright settings ===============
vim.o.updatetime = 250
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
end,
})

-- ================= C/C++ settings =================
local aug = vim.api.nvim_create_augroup("CStyle", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = aug, pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.tabstop     = 4
    vim.opt_local.shiftwidth  = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab   = true
    vim.opt_local.cindent     = true
  end
})

-- ================= Build / Run =================
vim.api.nvim_create_autocmd("FileType", {
  group = aug, pattern = { "c" },
  command = [[setlocal makeprg=gcc\ -std=c11\ -Wall\ -Wextra\ -Wpedantic\ -g\ %\ -o\ %:r]]
})
vim.api.nvim_create_autocmd("FileType", {
  group = aug, pattern = { "cpp" },
  command = [[setlocal makeprg=g++\ -std=c++17\ -Wall\ -Wextra\ -Wpedantic\ -g\ %\ -o\ %:r]]
})

-- Keymaps you had
vim.g.mapleader = " "
local map = vim.keymap.set
map("n", "<F5>", ":w<CR>:make<CR>", { silent = true })
map("n", "<F6>", ":copen<CR>", { silent = true })
map("n", "<F9>", ":!./%:r<CR>", { silent = false })
map('t', '<C-w>N', [[<C-\><C-n>]], { noremap = true})

-- ================= Formatting =================
-- keep your clang-format binding; LSP format also available on <leader>lf
map("n", "<leader>f", [[:silent %!clang-format<CR>]], { silent = true })
