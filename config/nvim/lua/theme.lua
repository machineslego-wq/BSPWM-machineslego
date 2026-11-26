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
        hl.NeoTreeWinSeparator = { fg = "#3b4261", bg = "#16161e" }
        hl.StatusLine = { fg = "#c0caf5", bg = "#16161e" }
        hl.StatusLineNC = { fg = "#565f89", bg = "#16161e" }
        hl.WinSeparator = { fg = "#3b4261" }
        hl.Pmenu = { fg = "#c0caf5", bg = "#16161e" }
        hl.PmenuSel = { fg = "#c0caf5", bg = "#3b4261" }
    end,
})

vim.cmd.colorscheme("tokyonight-night")
