-- ==========================================================
-- lsp.lua — Mason + нативный LSP Neovim 0.11+
-- ==========================================================
-- Серверы ставятся один раз вручную: :Mason (UI) или
--   :MasonInstall lua_ls bashls pyright ...
-- Хоткеи кода — в keymaps.lua (M.lsp).
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
        require("keymaps").lsp(event.buf)
    end,
})
