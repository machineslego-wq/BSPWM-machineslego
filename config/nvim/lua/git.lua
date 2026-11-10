-- ==========================================================
-- git.lua — gitsigns (хунки, блейм, diff)
-- ==========================================================

require("gitsigns").setup({
    signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▏" },
        topdelete = { text = "▏" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
    },
    current_line_blame = false,
    on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
        end

        map("n", "]c", function()
            if vim.wo.diff then
                return "]c"
            end
            vim.schedule(function()
                gs.next_hunk()
            end)
            return "<Ignore>"
        end, "Следующий хунк")

        map("n", "[c", function()
            if vim.wo.diff then
                return "[c"
            end
            vim.schedule(function()
                gs.prev_hunk()
            end)
            return "<Ignore>"
        end, "Предыдущий хунк")

        map({ "n", "v" }, "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", "Застейджить хунк")
        map("n", "<leader>gr", gs.reset_hunk, "Сбросить хунк")
        map("n", "<leader>gp", gs.preview_hunk, "Просмотр хунка")
        map("n", "<leader>gb", function()
            gs.blame_line({ full = true })
        end, "Blame строки")
        map("n", "<leader>gd", gs.diffthis, "Diff файла")
    end,
})
