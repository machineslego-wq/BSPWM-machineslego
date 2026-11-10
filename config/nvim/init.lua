-- ==========================================================
-- init.lua — минимальный Neovim в стиле базового VS Code
-- Тема: Tokyo Night (night), палитра как в остальном репозитории.
-- Плагины: vim.pack (встроенный менеджер Neovim 0.12).
-- ==========================================================

require("options")
require("keymaps")
require("plugins")
require("theme")
require("treesitter")
require("completion")
require("lsp")
require("explorer")
require("git")
require("finder")
require("ui")
