-- ==========================================================
-- explorer.lua — neo-tree: сайдбар слева, ширина 32
-- ==========================================================

require("neo-tree").setup({
    window = {
        width = 32,
        mappings = {
            -- Пробел — leader, поэтому в дереве его действие отключено
            ["<space>"] = "none",
        },
    },
    filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
        },
    },
})

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Файловый сайдбар" })

-- Ширина сайдбара не меняется при открытии и закрытии сплитов
vim.api.nvim_create_autocmd("FileType", {
    pattern = "neo-tree",
    callback = function()
        vim.wo.winfixwidth = true
    end,
})

local function sidebar_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
            return win
        end
    end
end

local function editor_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "neo-tree" then
            return win
        end
    end
end

local function is_placeholder(buf)
    return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) == "" and not vim.bo[buf].modified
end

-- Флаг «нажат :q» (а не :bd): по нему отличаем выход из пустой области
local quitting = false
vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
        quitting = true
    end,
})

-- У Vim единственное окно всегда занимает весь экран, поэтому окно редактора
-- не даём закрыть: пока сайдбар открыт, справа остаётся рабочая область 32/остальное.
-- Пустая область отличается от файла: :q в ней выходит из Neovim, :bd — нет.
vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
        local win = tonumber(args.match)
        local closing = nil
        if win and vim.api.nvim_win_is_valid(win) then
            closing = vim.api.nvim_win_get_buf(win)
        end
        local empty = closing ~= nil and is_placeholder(closing)
        local quit = quitting
        quitting = false

        -- WinClosed срабатывает до удаления окна, поэтому буфер закрываемого
        -- окна читаем сразу, а новое окно создаём уже после закрытия
        vim.schedule(function()
            if vim.v.exiting ~= vim.NIL then
                return
            end

            local side = sidebar_win()
            if not side or editor_win() then
                return
            end

            if empty and quit then
                vim.cmd("qa")
                return
            end

            vim.cmd("rightbelow vnew")
            vim.bo.buflisted = false
            vim.api.nvim_win_set_width(side, 32)
        end)
    end,
})
