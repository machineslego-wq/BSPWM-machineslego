-- ==========================================================
-- treesitter.lua — подсветка синтаксиса
-- ==========================================================

require("nvim-treesitter").install({
    "c",
    "cpp",
    "lua",
    "vim",
    "vimdoc",
    "bash",
    "python",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "yaml",
    "toml",
    "html",
    "css",
    "scss",
    "markdown",
    "markdown_inline",
    "rust",
    "php",
    "dockerfile",
    "gitignore",
    "diff",
    "query",
    "regex",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
