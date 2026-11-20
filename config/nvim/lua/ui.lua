-- ==========================================================
-- ui.lua — lualine (статуслайн) и which-key
-- Вкладок-буферов нет: одиночный буфер, файлы меняются через дерево.
-- ==========================================================

require("lualine").setup({
    options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "|", right = "|" },
        disabled_filetypes = { "neo-tree" },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
})

require("which-key").setup({ preset = "modern" })

require("which-key").add({
    { "<leader>g", group = "Git" },
    { "<leader>c", group = "Код" },
})
