-- ==========================================================
-- explorer.lua — neo-tree: сайдбар слева, ширина 32
-- ==========================================================

require("neo-tree").setup({
    -- Сайдбар закрывается вместе с последним окном редактора, поэтому
    -- :q / :wq действительно выходят из Neovim, а не оставляют дерево
    -- на весь экран.
    close_if_last_window = true,
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
