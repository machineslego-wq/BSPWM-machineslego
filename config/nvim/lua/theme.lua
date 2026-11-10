-- ==========================================================
-- theme.lua — Tokyo Night (night), палитра репозитория
-- ==========================================================

require("tokyonight").setup({
    style = "night",
    terminal_colors = true,
    styles = {
        comments = { italic = true },
        keywords = { italic = false },
        sidebars = "dark",
        floats = "dark",
    },
    on_highlights = function(hl)
        -- Сайдбар и статуслайн в тон остальным конфигам
        hl.NeoTreeNormal = { fg = "#c0caf5", bg = "#16161e" }
        hl.NeoTreeNormalNC = { fg = "#c0caf5", bg = "#16161e" }
        hl.NeoTreeWinSeparator = { fg = "#292e42", bg = "#16161e" }
        hl.StatusLine = { fg = "#c0caf5", bg = "#1f2335" }
        hl.StatusLineNC = { fg = "#565f89", bg = "#1f2335" }
        hl.WinSeparator = { fg = "#292e42" }
        hl.Pmenu = { fg = "#c0caf5", bg = "#1f2335" }
        hl.PmenuSel = { fg = "#c0caf5", bg = "#2f334d" }
    end,
})

vim.cmd.colorscheme("tokyonight-night")
