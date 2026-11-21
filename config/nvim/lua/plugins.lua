-- ==========================================================
-- plugins.lua — единственное место со списком плагинов.
-- vim.pack ставит их в ~/.local/share/nvim/site/pack/core/opt,
-- версии фиксируются в nvim-pack-lock.json (лежит рядом).
-- ==========================================================

local gh = function(repo)
    return "https://github.com/" .. repo
end

vim.pack.add({
    -- Тема
    { src = gh("folke/tokyonight.nvim") },

    -- Синтаксис
    { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },

    -- LSP
    { src = gh("neovim/nvim-lspconfig") },
    { src = gh("mason-org/mason.nvim") },
    { src = gh("mason-org/mason-lspconfig.nvim") },

    -- Автодополнение
    { src = gh("saghen/blink.lib") },
    { src = gh("saghen/blink.cmp") },

    -- Файловый сайдбар
    { src = gh("nvim-neo-tree/neo-tree.nvim") },
    { src = gh("nvim-lua/plenary.nvim") },
    { src = gh("MunifTanjim/nui.nvim") },
    { src = gh("nvim-tree/nvim-web-devicons") },

    -- Git
    { src = gh("lewis6991/gitsigns.nvim") },

    -- Поиск
    { src = gh("nvim-telescope/telescope.nvim") },

    -- Статуслайн и подсказки по хоткеям
    { src = gh("nvim-lualine/lualine.nvim") },
    { src = gh("folke/which-key.nvim") },
})
