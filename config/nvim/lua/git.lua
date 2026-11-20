-- ==========================================================
-- git.lua — gitsigns (хунки, блейм, diff)
-- Хоткеи — в keymaps.lua (M.git).
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
        require("keymaps").git(bufnr)
    end,
})
