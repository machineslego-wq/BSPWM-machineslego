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

-- Пустой безымянный буфер (при старте без файла и после :bd) не должен
-- висеть вкладкой в tabline. Как только в нём что-то набрали или записали —
-- возвращаем его в список.
local function scratch(buf)
    return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) == ""
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function(args)
        if scratch(args.buf) and not vim.bo[args.buf].modified then
            vim.bo[args.buf].buflisted = false
        end
    end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    callback = function(args)
        if
            not vim.bo[args.buf].buflisted
            and (vim.bo[args.buf].modified or vim.api.nvim_buf_get_name(args.buf) ~= "")
        then
            vim.bo[args.buf].buflisted = true
        end
    end,
})
