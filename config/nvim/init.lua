-- ==========================================================
-- init.lua — минимальный Neovim: дерево + одиночный буфер
-- Тема: Tokyo Night (night), палитра как в остальном репозитории.
-- Плагины: vim.pack (встроенный менеджер Neovim 0.12).
--
-- Файлы по зонам ответственности (порядок загрузки важен):
--   options     — поведение редактора
--   keymaps     — общие хоткеи (окна, сохранить, выйти)
--   plugins     — единственный список плагинов
--   theme       — цвета
--   treesitter  — подсветка синтаксиса
--   completion  — автодополнение (blink.cmp)
--   lsp         — LSP-серверы и хоткеи кода
--   explorer    — дерево проекта (neo-tree)
--   git         — git-хунки (gitsigns)
--   ui          — статуслайн (lualine) и which-key
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
require("ui")
