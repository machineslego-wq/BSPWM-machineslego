-- ==========================================================
-- ui.lua — lualine (статуслайн)
-- Вкладок-буферов нет: одиночный буфер, файлы меняются через дерево.
-- which-key убран — хоткеи смотрят в CHEATSHEET.md.
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
