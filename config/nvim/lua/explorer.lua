-- ==========================================================
-- explorer.lua — neo-tree: сайдбар слева, ширина 32
-- Остальные настройки — стоковые.
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
