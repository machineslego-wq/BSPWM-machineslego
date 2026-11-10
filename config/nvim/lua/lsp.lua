-- ==========================================================
-- lsp.lua — Mason + нативный LSP Neovim 0.11+
-- ==========================================================

local servers = {
    "lua_ls",
    "bashls",
    "pyright",
    "ts_ls",
    "clangd",
    "rust_analyzer",
    "jsonls",
    "yamlls",
    "html",
    "cssls",
    "emmet_language_server",
    "intelephense",
}

-- Отложено: Go и Laravel-тулчейн ещё не установлены.
-- Когда появятся, добавить в servers выше и выполнить :MasonInstall gopls.
-- local later = { "gopls" }

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = servers,
    automatic_enable = false,
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
        },
    },
})

vim.lsp.config("pyright", {
    settings = {
        python = { analysis = { typeCheckingMode = "basic" } },
    },
})

vim.lsp.config("ts_ls", {
    init_options = { hostInfo = "neovim" },
})

vim.lsp.config("intelephense", {
    settings = {
        intelephense = {
            environment = { phpVersion = "8.4" },
            files = { maxSize = 5000000 },
        },
    },
})

vim.lsp.enable(servers)

vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = "●" },
    severity_sort = true,
    float = { border = "rounded", source = true },
    signs = true,
    underline = true,
    update_in_insert = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
        end

        map("gd", vim.lsp.buf.definition, "Перейти к определению")
        map("gD", vim.lsp.buf.declaration, "Перейти к объявлению")
        map("gr", vim.lsp.buf.references, "Ссылки")
        map("gi", vim.lsp.buf.implementation, "Реализации")
        map("K", vim.lsp.buf.hover, "Документация")
        map("<leader>rn", vim.lsp.buf.rename, "Переименовать")
        map("<leader>ca", vim.lsp.buf.code_action, "Действия кода")
        map("<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, "Форматировать")
        map("<leader>cd", vim.diagnostic.open_float, "Диагностика строки")
        map("[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, "Предыдущая диагностика")
        map("]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, "Следующая диагностика")
    end,
})
