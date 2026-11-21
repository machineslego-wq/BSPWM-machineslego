-- ==========================================================
-- ui.lua — lualine и which-key
-- ==========================================================

require("lualine").setup({
    options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "|", right = "|" },
        disabled_filetypes = { "neo-tree" },
    },
    tabline = {
        lualine_a = {
            {
                "buffers",
                mode = 2,
                show_modified_status = true,
                symbols = { modified = " ●", alternate_file = "", directory = "" },
            },
        },
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
    { "<leader>f", group = "Поиск" },
    { "<leader>b", group = "Буферы" },
    { "<leader>g", group = "Git" },
    { "<leader>c", group = "Код" },
})
