-- ==========================================================
-- keymaps.lua — общие хоткеи (leader = пробел)
-- ==========================================================

local map = vim.keymap.set

-- Буферы
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Следующий буфер" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Предыдущий буфер" })

-- Закрытие текущего буфера: окно остаётся, пустая заглушка одна и не listed
map("n", "<leader>bd", function()
    require("buffers").close_current()
end, { desc = "Закрыть буфер" })

-- Окна (в т.ч. переход из сайдбара в редактор и обратно)
map("n", "<C-h>", "<C-w>h", { desc = "Окно влево" })
map("n", "<C-j>", "<C-w>j", { desc = "Окно вниз" })
map("n", "<C-k>", "<C-w>k", { desc = "Окно вверх" })
map("n", "<C-l>", "<C-w>l", { desc = "Окно вправо" })

-- Файлы
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Сохранить" })
map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Выйти" })

-- Сброс подсветки поиска
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Убрать подсветку поиска" })

-- Встроенный терминал: один и тот же буфер, открыть/скрыть
local term_buf

function _G.toggle_terminal()
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        local win = vim.fn.bufwinid(term_buf)
        if win ~= -1 then
            vim.api.nvim_win_hide(win)
        else
            vim.cmd("botright sbuffer " .. term_buf)
            vim.cmd("startinsert")
        end
        return
    end

    vim.cmd("botright split")
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
    vim.cmd("startinsert")
end

map("n", "<C-\\>", toggle_terminal, { desc = "Терминал" })
map("t", "<C-\\>", toggle_terminal, { desc = "Терминал" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Выйти из режима терминала" })
