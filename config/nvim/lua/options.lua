-- ==========================================================
-- options.lua — поведение редактора
-- ==========================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- neo-tree заменяет встроенный netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- Внешний вид
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = false
opt.termguicolors = true
opt.background = "dark"
opt.laststatus = 3
opt.winborder = "rounded"
opt.fillchars = { eob = " " }
opt.showmode = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Мышь и системный буфер обмена (xclip/xsel уже есть)
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Отступы
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- Поиск
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Файлы и история
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.confirm = true

-- Окна
opt.splitright = true
opt.splitbelow = true
opt.wrap = false

-- Быстрее реагируют gitsigns/diagnostics/which-key
opt.updatetime = 300
opt.timeoutlen = 400
