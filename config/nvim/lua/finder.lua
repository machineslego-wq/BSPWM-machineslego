-- ==========================================================
-- finder.lua — telescope (файлы и grep через ripgrep)
-- ==========================================================

require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            "^%.git/",
            "node_modules/",
            "target/",
            "__pycache__/",
            "vendor/",
        },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        },
    },
    pickers = {
        find_files = {
            find_command = {
                "rg",
                "--files",
                "--color=never",
                "--hidden",
                "--glob=!.git/*",
            },
        },
    },
})

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Найти файл" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep по проекту" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Буферы" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Справка Neovim" })
