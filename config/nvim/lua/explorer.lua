-- ==========================================================
-- explorer.lua — neo-tree: сайдбар слева, ширина 32
-- ==========================================================

require("neo-tree").setup({
    -- Стоковое поведение: :bd закрывает окно редактора, сайдбар остаётся.
    -- Поэтому false — иначе закрытие буфера завершало бы Neovim целиком.
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
