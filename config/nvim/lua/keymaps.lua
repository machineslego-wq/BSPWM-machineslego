-- ==========================================================
-- keymaps.lua — ВСЕ сочетания клавиш в одном файле
--
-- Общие хоткеи объявлены глобально. LSP- и git-хоткеи — буферные
-- функции M.lsp(buf) / M.git(buf), их вызывают lsp.lua (LspAttach)
-- и git.lua (on_attach). Больше ни в одном файле map'ов нет.
-- ==========================================================

local map = vim.keymap.set

local M = {}

-- ============ Общие (глобальные) ============

-- Окна: дерево <-> редактор (это эквиваленты <C-w>h/j/k/l)
map("n", "<C-h>", "<C-w>h", { desc = "Окно влево (в дерево)" })
map("n", "<C-j>", "<C-w>j", { desc = "Окно вниз" })
map("n", "<C-k>", "<C-w>k", { desc = "Окно вверх" })
map("n", "<C-l>", "<C-w>l", { desc = "Окно вправо (в редактор)" })

-- Дерево проекта
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Дерево проекта" })

-- Файл и выход
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Сохранить" })
map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Выйти из Neovim" })

-- Сброс подсветки поиска
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Убрать подсветку поиска" })

-- ============ LSP (буферные, вешает lsp.lua) ============

function M.lsp(buf)
    local b = function(keys, func, desc)
        map("n", keys, func, { buffer = buf, desc = desc })
    end

    -- `gd`/`gD`/`K` переопределяют стоковые ctags/manpage: без LSP они
    -- всё равно ничего не делают, поэтому это штатный LSP-набор.
    b("gd", vim.lsp.buf.definition, "Перейти к определению")
    b("gD", vim.lsp.buf.declaration, "Перейти к объявлению")
    b("gr", vim.lsp.buf.references, "Ссылки")
    b("K", vim.lsp.buf.hover, "Документация")
    -- `gi` (сток: перейти к последней правке) не трогаем — реализация
    -- переехала на <leader>ci, чтобы не терять стоковое поведение.
    b("<leader>ci", vim.lsp.buf.implementation, "Реализации")
    b("<leader>rn", vim.lsp.buf.rename, "Переименовать")
    b("<leader>ca", vim.lsp.buf.code_action, "Действия кода")
    b("<leader>f", function()
        vim.lsp.buf.format({ async = true })
    end, "Форматировать")
    b("<leader>cd", vim.diagnostic.open_float, "Диагностика строки")
    b("[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
    end, "Предыдущая ошибка")
    b("]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
    end, "Следующая ошибка")
end

-- ============ Git (буферные, вешает git.lua) ============

function M.git(buf)
    local gs = require("gitsigns")
    local b = function(keys, func, desc)
        map("n", keys, func, { buffer = buf, desc = desc })
    end

    -- В diff-режиме ]c/[c остаются стоковыми, иначе — хунки gitsigns.
    b("]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
    end, "Следующий хунк")
    b("[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
    end, "Предыдущий хунк")
    map({ "n", "v" }, "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>",
        { buffer = buf, desc = "Застейджить хунк" })
    b("<leader>gr", gs.reset_hunk, "Сбросить хунк")
    b("<leader>gp", gs.preview_hunk, "Просмотр хунка")
    b("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame строки")
    b("<leader>gd", gs.diffthis, "Diff файла")
end

return M
