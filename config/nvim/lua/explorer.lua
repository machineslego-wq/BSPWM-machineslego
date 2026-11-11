-- ==========================================================
-- explorer.lua — neo-tree
-- ==========================================================

require("neo-tree").setup({
    -- Не закрывать сайдбар, когда редактор остался без вкладок:
    -- иначе :bd завершает Neovim. Окно редактора сохраняет заглушка.
    close_if_last_window = false,
    window = {
        width = 32,
        mappings = {
            ["<space>"] = "none",
            ["<cr>"] = "open",
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

local buffers = require("buffers")

local function is_empty_listed(buf)
    return vim.api.nvim_buf_is_valid(buf)
        and vim.bo[buf].buftype == ""
        and vim.bo[buf].filetype ~= "neo-tree"
        and vim.api.nvim_buf_get_name(buf) == ""
        and not vim.bo[buf].modified
end

local function editor_windows()
    local wins = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "neo-tree" then
            wins[#wins + 1] = win
        end
    end
    return wins
end

local function sidebar_window()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
            return win
        end
    end
end

-- Держим окно редактора рядом с сайдбаром и не даём плодиться пустым вкладкам.
-- Вызывается после :bd.
local function ensure_editor_area(deleted)
    -- BufDelete срабатывает до фактического закрытия окна
    vim.defer_fn(function()
        -- v:exiting равен v:null, пока Neovim не завершается
        if vim.v.exiting ~= vim.NIL then
            return
        end

        local wins = editor_windows()

        -- Пустые буферы, которые Vim создал после :bd, заменяем на заглушку
        for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if buf ~= deleted and is_empty_listed(buf) then
                local placeholder = buffers.placeholder(buf)
                buffers.show(win, placeholder)
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
        end

        if #wins > 0 then
            buffers.prune()
            return
        end

        -- Окна редактора не осталось (например, :bd закрыл последнее)
        local sidebar = sidebar_window()
        if not sidebar then
            return
        end

        -- Предыдущий буфер, иначе первый из открытых, иначе пустая заглушка
        local target = vim.fn.bufnr("#")
        if
            target < 1
            or target == deleted
            or vim.fn.bufexists(target) ~= 1
            or vim.fn.buflisted(target) ~= 1
        then
            local listed = vim.fn.getbufinfo({ buflisted = 1 })
            target = listed[1] and listed[1].bufnr or buffers.placeholder()
        end

        vim.cmd("botright vsplit")
        buffers.show(0, target)
        vim.api.nvim_win_set_width(sidebar, 32)
    end, 50)
end

vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(args)
        -- Служебные буферы и заглушки не восстанавливают окно
        if vim.bo[args.buf].buftype ~= "" or vim.api.nvim_buf_get_name(args.buf) == "" then
            return
        end
        ensure_editor_area(args.buf)
    end,
})
